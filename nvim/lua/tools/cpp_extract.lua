local M = {}

local HEADER_PATTERNS = { "%.h$", "%.hh$", "%.hpp$", "%.hxx$" }
local STRIP_DECL_KEYWORDS = { "static", "inline", "virtual", "friend", "explicit", "override" }

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "CppExtractDefinitions" })
end

local function is_header(path)
	for _, pattern in ipairs(HEADER_PATTERNS) do
		if path:match(pattern) then return true end
	end

	return false
end

local function trim(text)
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function split_lines(text)
	return vim.split(text, "\n", { plain = true })
end

local function get_node_text(node, bufnr)
	return vim.treesitter.get_node_text(node, bufnr)
end

local function get_field_child(node, field)
	if not node then return nil end

	if node.child_by_field_name then
		return node:child_by_field_name(field)
	end

	if node.field then
		local children = node:field(field)
		if children and children[1] then return children[1] end
	end

	return nil
end

local function get_text_range(bufnr, start_row, start_col, end_row, end_col)
	return table.concat(vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {}), "\n")
end

local function normalize_ws(text)
	return trim((text:gsub("%s+", " ")))
end

local function node_contains(node, row, col)
	local sr, sc, er, ec = node:range()
	if row < sr or row > er then return false end
	if row == sr and col < sc then return false end
	if row == er and col >= ec then return false end
	return true
end

local function iter_named_children(node)
	local index = 0
	local count = node:named_child_count()

	return function()
		if index >= count then return nil end
		local child = node:named_child(index)
		index = index + 1
		return child
	end
end

local function find_enclosing_class(node, row, col)
	local best = nil

	local function walk(current)
		if not node_contains(current, row, col) then return end

		local kind = current:type()
		if kind == "class_specifier" or kind == "struct_specifier" then
			best = current
		end

		for child in iter_named_children(current) do
			walk(child)
		end
	end

	walk(node)
	return best
end

local function find_enclosing_function(node, row, col)
	local best = nil

	local function walk(current)
		if not node_contains(current, row, col) then return end

		if current:type() == "function_definition" then
			best = current
		end

		for child in iter_named_children(current) do
			walk(child)
		end
	end

	walk(node)
	return best
end

local function find_first_named_child(node, wanted_type)
	for child in iter_named_children(node) do
		if child:type() == wanted_type then return child end
	end

	return nil
end

local function find_direct_named_child(node, wanted_type)
	if not node then return nil end

	for child in iter_named_children(node) do
		if child:type() == wanted_type then return child end
	end

	return nil
end

local function has_template_ancestor(node)
	local current = node and node:parent() or nil

	while current do
		if current:type() == "template_declaration" then return true end
		current = current:parent()
	end

	return false
end

local function get_class_name(class_node, bufnr)
	local name_node = get_field_child(class_node, "name")
	if name_node then return trim(get_node_text(name_node, bufnr)) end

	for child in iter_named_children(class_node) do
		local kind = child:type()
		if kind == "type_identifier" or kind == "identifier" then
			return trim(get_node_text(child, bufnr))
		end
	end

	return nil
end

local function parse_namespace_name(ns_node, bufnr)
	local name_node = get_field_child(ns_node, "name")
	if name_node then
		local text = trim(get_node_text(name_node, bufnr))
		if text ~= "" then return text end
	end

	local text = get_node_text(ns_node, bufnr)
	local header = text:match("^[^{]+") or text
	return trim((header:match("namespace%s+([%w_:]+)") or ""))
end

local function get_namespace_parts(node, bufnr)
	local parts = {}
	local current = node and node:parent() or nil

	while current do
		if current:type() == "namespace_definition" then
			local name = parse_namespace_name(current, bufnr)
			if name ~= "" then
				local namespace_parts = {}
				for _, part in ipairs(vim.split(name, "::", { plain = true })) do
					if part ~= "" then table.insert(namespace_parts, part) end
				end

				for index = #namespace_parts, 1, -1 do
					table.insert(parts, 1, namespace_parts[index])
				end
			end
		end

		current = current:parent()
	end

	return parts
end

local function find_class_body(class_node)
	return get_field_child(class_node, "body") or find_first_named_child(class_node, "field_declaration_list")
end

local function find_containing_class(node)
	local current = node and node:parent() or nil

	while current do
		local kind = current:type()
		if kind == "class_specifier" or kind == "struct_specifier" then return current end
		current = current:parent()
	end

	return nil
end

local function resolve_function_name_node(declarator)
	if not declarator then return nil end

	local kind = declarator:type()
	if kind == "qualified_identifier" then
		return get_field_child(declarator, "name") or declarator
	end

	if kind == "identifier" or kind == "field_identifier" or kind == "operator_name" or kind == "destructor_name" then
		return declarator
	end

	local name_node = get_field_child(declarator, "name")
	if name_node then return name_node end

	local inner = get_field_child(declarator, "declarator")
	if inner then
		return resolve_function_name_node(inner)
	end

	if declarator:named_child_count() == 1 then
		return resolve_function_name_node(declarator:named_child(0))
	end

	return declarator
end

-- Unwraps pointer/reference declarators down to the function_declarator, if any
local function find_function_declarator(node)
	local current = get_field_child(node, "declarator")

	while current and current:type() ~= "function_declarator" do
		-- reference_declarator carries its inner declarator unnamed
		current = get_field_child(current, "declarator")
			or (current:type() == "reference_declarator" and current:named_child(0) or nil)
	end

	return current
end

-- e.g. "Box::a", "Shop::Box::~Box", "operator==" (whitespace removed for comparison)
local function function_declarator_name(function_declarator, source)
	local name_node = get_field_child(function_declarator, "declarator")
	return name_node and (get_node_text(name_node, source):gsub("%s+", "")) or nil
end

local function function_declarator_params(function_declarator, source)
	local params_node = get_field_child(function_declarator, "parameters")
	return params_node and (get_node_text(params_node, source):gsub("%s+", "")) or ""
end

local function strip_decl_only_keywords(text)
	local updated = text

	for _, keyword in ipairs(STRIP_DECL_KEYWORDS) do
		updated = updated:gsub("(%f[%a_])" .. keyword .. "(%f[^%a_])%s*", "")
	end

	return updated
end

local function build_definition_prefix(bufnr, function_node, scope_prefix)
	local body_node = get_field_child(function_node, "body")
	local declarator = get_field_child(function_node, "declarator")
	if not body_node or not declarator then return nil, "Unsupported function declarator" end

	local name_node = resolve_function_name_node(declarator)
	if not name_node then return nil, "Unsupported function name" end

	local fsr, fsc = function_node:range()
	local bsr, bsc = body_node:range()
	local nsr, nsc, ner, nec = name_node:range()
	local prefix = get_text_range(bufnr, fsr, fsc, bsr, bsc)

	local before_name = get_text_range(bufnr, fsr, fsc, nsr, nsc)
	local after_name = get_text_range(bufnr, ner, nec, bsr, bsc)
	local scoped_name = scope_prefix .. get_node_text(name_node, bufnr)

	local rewritten = before_name .. scoped_name .. after_name
	return trim(strip_decl_only_keywords(rewritten)), nil
end

local function build_declaration(bufnr, function_node)
	local body_node = get_field_child(function_node, "body")
	if not body_node then return nil end

	local fsr, fsc = function_node:range()
	local end_row, end_col = body_node:range()
	local initializer_list = find_direct_named_child(function_node, "field_initializer_list")
	if initializer_list then
		end_row, end_col = initializer_list:range()
	end

	local prefix = trim(get_text_range(bufnr, fsr, fsc, end_row, end_col))
	return prefix .. ";"
end

local function build_free_function_declaration(bufnr, function_node)
	local declaration = build_declaration(bufnr, function_node)
	if not declaration then return nil end

	return trim(strip_decl_only_keywords(declaration))
end

local function collect_inline_member_functions(class_node)
	local body = find_class_body(class_node)
	if not body then return {} end

	local functions = {}

	local function walk(node)
		for child in iter_named_children(node) do
			local kind = child:type()

			if kind == "class_specifier" or kind == "struct_specifier" then
				-- Ignore nested types while processing the current class.
			elseif kind == "function_definition" then
				if not has_template_ancestor(child) then
					table.insert(functions, child)
				end
			else
				walk(child)
			end
		end
	end

	walk(body)
	table.sort(functions, function(a, b)
		local ar = { a:range() }
		local br = { b:range() }
		if ar[1] == br[1] then return ar[2] < br[2] end
		return ar[1] < br[1]
	end)

	return functions
end

local function build_definition_text(bufnr, function_node, scope_prefix)
	local prefix, err = build_definition_prefix(bufnr, function_node, scope_prefix)
	if not prefix then return nil, err end

	local body_node = get_field_child(function_node, "body")
	local body = get_node_text(body_node, bufnr)
	return prefix .. " " .. body
end

local function wrap_in_namespaces(namespace_parts, definitions)
	if vim.tbl_isempty(definitions) then return {} end

	if vim.tbl_isempty(namespace_parts) then
		local lines = {}
		for index, definition in ipairs(definitions) do
			if index > 1 then table.insert(lines, "") end
			vim.list_extend(lines, split_lines(definition))
		end
		return lines
	end

	local lines = { "namespace " .. table.concat(namespace_parts, "::") .. " {", "" }

	for index, definition in ipairs(definitions) do
		if index > 1 then table.insert(lines, "") end
		vim.list_extend(lines, split_lines(definition))
	end

	table.insert(lines, "")
	table.insert(lines, "}")
	return lines
end

local function flatten_namespace_stack(stack)
	local parts = {}

	for _, entry in ipairs(stack) do
		vim.list_extend(parts, entry.parts)
	end

	return parts
end

local function namespace_parts_equal(left, right)
	if #left ~= #right then return false end

	for index = 1, #left do
		if left[index] ~= right[index] then return false end
	end

	return true
end

local function parse_namespace_decl_parts(line)
	local name = line:match("^%s*namespace%s+([%w_:]+)%s*{")
	if not name or name == "" then return nil end

	local parts = {}
	for _, part in ipairs(vim.split(name, "::", { plain = true })) do
		if part ~= "" then table.insert(parts, part) end
	end

	if vim.tbl_isempty(parts) then return nil end
	return parts
end

local function find_namespace_insert_index(lines, namespace_parts)
	if vim.tbl_isempty(namespace_parts) then return nil end

	local brace_depth = 0
	local namespace_stack = {}
	local target_entry = nil

	for index, line in ipairs(lines) do
		local decl_parts = parse_namespace_decl_parts(line)
		if decl_parts then
			local entry = {
				parts = decl_parts,
				close_depth = brace_depth,
			}
			table.insert(namespace_stack, entry)
			if namespace_parts_equal(flatten_namespace_stack(namespace_stack), namespace_parts) then
				target_entry = entry
			end
		end

		local opens = select(2, line:gsub("{", ""))
		local closes = select(2, line:gsub("}", ""))
		brace_depth = brace_depth + opens - closes

		while #namespace_stack > 0 and brace_depth == namespace_stack[#namespace_stack].close_depth do
			local closing_entry = table.remove(namespace_stack)
			if closing_entry == target_entry then
				return index
			end
		end
	end

	return nil
end

local function insert_lines_at(lines, insert_at, new_lines)
	for offset = #new_lines, 1, -1 do
		table.insert(lines, insert_at, new_lines[offset])
	end
end

-----------------------------------------------------------------------
-- Header-order placement: a new definition goes next to its nearest
-- header neighbour that is already defined in the .cpp
-----------------------------------------------------------------------

local function is_header_scope_container(kind)
	return kind:match("^preproc_") ~= nil or kind == "linkage_specification" or kind == "declaration_list"
end

local function is_cpp_scope_container(kind)
	return is_header_scope_container(kind) or kind == "namespace_definition"
end

-- Visits function declarations/definitions under `node`, entering only containers
-- that keep the same scope (so nested classes/namespaces/templates are skipped)
local function each_function(node, is_container, visit)
	for child in iter_named_children(node) do
		local function_declarator = find_function_declarator(child)
		if function_declarator then
			visit(child, function_declarator)
		elseif is_container(child:type()) then
			each_function(child, is_container, visit)
		end
	end
end

-- Functions of one header scope in source order, keyed as a .cpp would name them
-- relative to the enclosing namespace (e.g. "Box::a" for members, "helper" for free functions)
local function scope_function_order(scope_node, bufnr, scope_prefix)
	local order = {}

	each_function(scope_node, is_header_scope_container, function(node, function_declarator)
		local name = function_declarator_name(function_declarator, bufnr)
		if name then
			table.insert(order, {
				key = scope_prefix .. name,
				params = function_declarator_params(function_declarator, bufnr),
				id = node:id(),
			})
		end
	end)

	return order
end

local function enclosing_scope(node)
	local current = node:parent()

	while current and current:type() ~= "declaration_list" and current:type() ~= "translation_unit" do
		current = current:parent()
	end

	return current
end

-- Doc comments directly above a definition belong to it
local function first_row_with_leading_comments(node)
	local first_row = node:start()
	local previous = node:prev_named_sibling()

	while previous and previous:type() == "comment" and select(3, previous:range()) >= first_row - 1 do
		-- A comment sharing its line with earlier code trails that code instead
		local before = previous:prev_sibling()
		if before and select(3, before:range()) == previous:start() then break end

		first_row = previous:start()
		previous = previous:prev_named_sibling()
	end

	return first_row
end

-- Moving a definition across a namespace, extern "C" or #if boundary changes its meaning
local function scope_context_id(node)
	local current = node:parent()

	while current do
		local kind = current:type()
		if kind == "namespace_definition" or kind == "linkage_specification" or kind:match("^preproc_") then
			return current:id()
		end
		current = current:parent()
	end

	return "root"
end

local function cpp_definition_spans(lines)
	local source = table.concat(lines, "\n")
	local ok, parser = pcall(vim.treesitter.get_string_parser, source, "cpp")
	if not ok or not parser then return {} end

	local spans = {}
	each_function(parser:parse()[1]:root(), is_cpp_scope_container, function(node, function_declarator)
		local name = node:type() == "function_definition" and function_declarator_name(function_declarator, source)
		if name then
			table.insert(spans, {
				name = name,
				params = function_declarator_params(function_declarator, source),
				context = scope_context_id(node),
				first_row = first_row_with_leading_comments(node),
				last_row = select(3, node:range()),
			})
		end
	end)

	return spans
end

-- "Box::a" and "Shop::Box::a" both name Shop::Box::a; "Other::a" does not
local function names_same_function(cpp_name, key, namespace_parts)
	local full_name = table.concat(vim.list_extend(vim.deepcopy(namespace_parts), { key }), "::")
	return #cpp_name >= #key and (full_name == cpp_name or full_name:sub(-(#cpp_name + 2)) == "::" .. cpp_name)
end

local function spans_for_key(spans, key, namespace_parts)
	return vim.tbl_filter(function(span)
		return names_same_function(span.name, key, namespace_parts)
	end, spans)
end

local function order_position(member_order, node)
	for index, member in ipairs(member_order) do
		if member.id == node:id() then return index end
	end

	return nil
end

-- An anchor spelled exactly as its key sits inside the namespace block, so the short
-- definition resolves there; any other spelling means the definition must be fully qualified
local function definition_matching_anchor(entry, anchor_key, anchor_span)
	return anchor_span.name == anchor_key and entry.definition or entry.full_definition
end

-- 1-based line index and definition text, or nil when no header neighbour is defined in the .cpp yet
local function anchored_insertion(lines, entry, member_order, namespace_parts)
	local position = order_position(member_order, entry.node)
	if not position then return nil end

	local spans = cpp_definition_spans(lines)

	for index = position - 1, 1, -1 do
		local key = member_order[index].key
		local previous = spans_for_key(spans, key, namespace_parts)
		local anchor = previous[#previous]
		if anchor then return anchor.last_row + 2, definition_matching_anchor(entry, key, anchor) end
	end

	for index = position + 1, #member_order do
		local key = member_order[index].key
		local anchor = spans_for_key(spans, key, namespace_parts)[1]
		if anchor then return anchor.first_row + 1, definition_matching_anchor(entry, key, anchor) end
	end

	return nil
end

-- Pads with blank lines only where the neighbours are not already blank
local function insert_definition(lines, insert_at, definition)
	local chunk = split_lines(definition)
	local before, after = lines[insert_at - 1], lines[insert_at]

	if before and trim(before) ~= "" then table.insert(chunk, 1, "") end
	if after and trim(after) ~= "" then table.insert(chunk, "") end

	insert_lines_at(lines, insert_at, chunk)
end

-- Overloads share a key, so an exact parameter-list match picks the right one;
-- otherwise the first declaration of that name decides
local function header_position(member_order, span, namespace_parts)
	local fallback

	for index, member in ipairs(member_order) do
		if names_same_function(span.name, member.key, namespace_parts) then
			if member.params == span.params then return index, member.key end
			fallback = fallback or index
		end
	end

	return fallback, fallback and member_order[fallback].key
end

local function replace_line_range(lines, first, last, replacement)
	for _ = first, last do
		table.remove(lines, first)
	end

	insert_lines_at(lines, first, replacement)
end

-- Permutes the scope's .cpp definitions into header order within the slots they already
-- occupy. A definition only trades places with others from the same namespace/#if block
-- spelled with the same qualification, so it still resolves where it lands; code that
-- belongs to no header function never moves. Returns how many definitions moved.
local function reorder_to_header_order(lines, member_order, namespace_parts)
	local groups = {}

	for index, span in ipairs(cpp_definition_spans(lines)) do
		local position, key = header_position(member_order, span, namespace_parts)
		if position then
			local group_key = span.context .. "|" .. span.name:sub(1, #span.name - #key)
			groups[group_key] = groups[group_key] or {}
			table.insert(groups[group_key], { span = span, position = position, index = index })
		end
	end

	local moves = {}
	for _, slots in pairs(groups) do
		local in_header_order = vim.list_extend({}, slots)
		table.sort(in_header_order, function(a, b)
			if a.position ~= b.position then return a.position < b.position end
			return a.index < b.index
		end)

		for slot_index, slot in ipairs(slots) do
			local incoming = in_header_order[slot_index]
			if incoming ~= slot then
				table.insert(moves, {
					slot = slot.span,
					text = vim.list_slice(lines, incoming.span.first_row + 1, incoming.span.last_row + 1),
				})
			end
		end
	end

	-- Bottom-up so the slots above keep their row numbers
	table.sort(moves, function(a, b) return a.slot.first_row > b.slot.first_row end)
	for _, move in ipairs(moves) do
		replace_line_range(lines, move.slot.first_row + 1, move.slot.last_row + 1, move.text)
	end

	return #moves
end

local function replace_function_with_declaration(bufnr, function_node, declaration)
	local sr, sc, er, ec = function_node:range()
	vim.api.nvim_buf_set_text(bufnr, sr, sc, er, ec, split_lines(declaration))
end

-- Nearest ancestor named `include`; marks an include/ + src/ project layout
local function find_include_dir(header_path)
	for dir in vim.fs.parents(header_path) do
		if vim.fs.basename(dir) == "include" then return dir end
	end

	return nil
end

-- Spelled relative to the include dir, since that is what the compiler's -I points at
local function header_include_line(header_path)
	local include_dir = find_include_dir(header_path)
	local include_path = include_dir and vim.fs.relpath(include_dir, header_path) or vim.fs.basename(header_path)
	return string.format('#include "%s"', include_path)
end

local function included_path(line)
	return line:match('^%s*#%s*include%s*["<]([^">]+)[">]')
end

local function ensure_cpp_include(cpp_path, include_line)
	local lines = {}
	if vim.fn.filereadable(cpp_path) == 1 then
		lines = vim.fn.readfile(cpp_path)
	end

	-- Any spelling of the same header counts, e.g. "Bar.h" vs "myproj/Bar.h"
	local header_name = vim.fs.basename(included_path(include_line))
	for _, line in ipairs(lines) do
		local path = included_path(line)
		if path and vim.fs.basename(path) == header_name then return lines, false end
	end

	if #lines == 0 then
		return { include_line, "" }, true
	end

	table.insert(lines, 1, "")
	table.insert(lines, 1, include_line)
	return lines, true
end

local function missing_entries(lines, definition_entries)
	local normalized_existing = normalize_ws(table.concat(lines, "\n"))
	local missing = {}

	for _, entry in ipairs(definition_entries) do
		local has_local = normalized_existing:find(entry.local_signature, 1, true) ~= nil
		local has_full = normalized_existing:find(entry.full_signature, 1, true) ~= nil
		if not has_local and not has_full then
			table.insert(missing, entry)
			normalized_existing = normalized_existing .. " " .. normalize_ws(entry.definition)
		end
	end

	return missing
end

-- Fallback when nothing from the same header scope is defined in the .cpp yet
local function append_at_scope_end(lines, definitions, namespace_parts)
	local insert_at = find_namespace_insert_index(lines, namespace_parts)
	if insert_at then
		local payload = wrap_in_namespaces({}, definitions)
		local chunk = {}
		local previous_line = lines[insert_at - 1]
		if previous_line and trim(previous_line) ~= "" then table.insert(chunk, "") end
		vim.list_extend(chunk, payload)
		if #chunk > 0 and trim(chunk[#chunk]) ~= "" then table.insert(chunk, "") end
		insert_lines_at(lines, insert_at, chunk)
	else
		if #lines > 0 and lines[#lines] ~= "" then table.insert(lines, "") end
		vim.list_extend(lines, wrap_in_namespaces(namespace_parts, definitions))
	end
end

-- Adds missing definitions, then brings the whole scope into header order.
-- `definition_entries` must be in header order so each one can anchor on the previous.
-- Returns (appended, reordered); an absent .cpp with nothing to add is left absent.
local function sync_cpp_definitions(cpp_path, include_line, definition_entries, namespace_parts, member_order)
	if vim.tbl_isempty(definition_entries) and vim.fn.filereadable(cpp_path) == 0 then
		return 0, 0
	end

	local lines, changed = ensure_cpp_include(cpp_path, include_line)
	local new_entries = missing_entries(lines, definition_entries)
	local unanchored = {}

	for _, entry in ipairs(new_entries) do
		local insert_at, definition = anchored_insertion(lines, entry, member_order, namespace_parts)
		if insert_at then
			insert_definition(lines, insert_at, definition)
		else
			table.insert(unanchored, entry.definition)
		end
	end

	if #unanchored > 0 then
		append_at_scope_end(lines, unanchored, namespace_parts)
	end

	local reordered = reorder_to_header_order(lines, member_order, namespace_parts)

	while #lines > 0 and lines[#lines] == "" do
		table.remove(lines)
	end

	if changed or #new_entries > 0 or reordered > 0 then
		vim.fn.mkdir(vim.fs.dirname(cpp_path), "p")
		vim.fn.writefile(lines, cpp_path)
	end

	return #new_entries, reordered
end

local function sync_summary(appended, reordered, cpp_path)
	local target = vim.fn.fnamemodify(cpp_path, ":~:.")
	if appended == 0 and reordered == 0 then
		return target .. " already matches the header"
	end

	return string.format("appended %d and reordered %d definition(s) in %s", appended, reordered, target)
end

-- <base>/include/<sub>/foo.h -> <base>/src/<sub>/foo.cpp. An existing, unambiguous
-- foo.cpp elsewhere under src/ wins so definitions never get split across two files.
-- Headers outside any include/ dir keep their .cpp alongside them.
local function header_to_cpp_path(path)
	local include_dir = find_include_dir(path)
	if not include_dir then
		return vim.fn.fnamemodify(path, ":r") .. ".cpp"
	end

	local src_dir = vim.fs.joinpath(vim.fs.dirname(include_dir), "src")
	local mirrored = vim.fs.joinpath(src_dir, vim.fn.fnamemodify(vim.fs.relpath(include_dir, path), ":r") .. ".cpp")
	if vim.fn.filereadable(mirrored) == 1 then return mirrored end

	local cpp_name = vim.fn.fnamemodify(path, ":t:r") .. ".cpp"
	local existing = vim.fs.find(cpp_name, { path = src_dir, type = "file", limit = 2 })
	return #existing == 1 and existing[1] or mirrored
end

local function get_cpp_parser_tree(bufnr)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "cpp")
	if not ok or not parser then
		notify("C++ Treesitter parser is not available", vim.log.levels.ERROR)
		return nil
	end

	local tree = parser:parse()[1]
	if not tree then
		notify("Unable to parse the current buffer", vim.log.levels.ERROR)
		return nil
	end

	return tree
end

local function build_definition_entry(bufnr, function_node, declaration_builder, scope_prefix, full_scope_prefix)
	local declaration = declaration_builder(bufnr, function_node)
	local definition, err = build_definition_text(bufnr, function_node, scope_prefix)
	if not declaration or not definition then return nil, err end

	local local_signature = normalize_ws(definition:match("^(.-)%s*%b{}") or definition)
	local full_definition = build_definition_text(bufnr, function_node, full_scope_prefix)
	local full_signature = normalize_ws((full_definition or definition):match("^(.-)%s*%b{}") or (full_definition or definition))

	return {
		definition = definition,
		full_definition = full_definition or definition,
		declaration = declaration,
		local_signature = local_signature,
		full_signature = full_signature,
		node = function_node,
	}, nil
end

local function extract_class_functions(functions, class_node, bufnr, path)
	local class_name = get_class_name(class_node, bufnr)
	if not class_name then
		notify("Unable to resolve class name", vim.log.levels.ERROR)
		return
	end

	local namespace_parts = get_namespace_parts(class_node, bufnr)
	local class_scope_prefix = class_name .. "::"
	local member_order = scope_function_order(find_class_body(class_node), bufnr, class_scope_prefix)
	local full_scope_parts = vim.list_extend(vim.deepcopy(namespace_parts), { class_name })
	local full_scope_prefix = table.concat(full_scope_parts, "::") .. "::"
	local definition_entries = {}
	local replacements = {}

	for _, function_node in ipairs(functions) do
		local entry, err = build_definition_entry(bufnr, function_node, build_declaration, class_scope_prefix, full_scope_prefix)
		if entry then
			table.insert(definition_entries, entry)
			table.insert(replacements, { node = entry.node, declaration = entry.declaration })
		elseif err then
			notify(err, vim.log.levels.WARN)
		end
	end

	if not vim.tbl_isempty(functions) and vim.tbl_isempty(replacements) then
		notify("No supported inline member definitions found", vim.log.levels.WARN)
	end

	for index = #replacements, 1, -1 do
		local item = replacements[index]
		replace_function_with_declaration(bufnr, item.node, item.declaration)
	end

	if #replacements > 0 then vim.cmd("silent write") end

	-- With nothing to extract, a rerun still re-syncs the .cpp to the header order
	local cpp_path = header_to_cpp_path(path)
	if #replacements == 0 and vim.fn.filereadable(cpp_path) == 0 then
		notify(string.format(
			"No inline member definitions in %s and no %s to reorder",
			class_name,
			vim.fn.fnamemodify(cpp_path, ":~:.")
		))
		return
	end

	local include_line = header_include_line(path)
	local appended, reordered = sync_cpp_definitions(cpp_path, include_line, definition_entries, namespace_parts, member_order)
	local summary = sync_summary(appended, reordered, cpp_path)

	if #replacements > 0 then
		notify(string.format("Extracted %d definition(s) from %s; %s", #replacements, class_name, summary))
	else
		notify(class_name .. ": " .. summary)
	end
end

local function extract_namespace_function(function_node, bufnr, path)
	local namespace_parts = get_namespace_parts(function_node, bufnr)
	local full_scope_prefix = ""
	if not vim.tbl_isempty(namespace_parts) then
		full_scope_prefix = table.concat(namespace_parts, "::") .. "::"
	end

	local entry, err = build_definition_entry(
		bufnr,
		function_node,
		build_free_function_declaration,
		"",
		full_scope_prefix
	)
	if not entry then
		notify(err or "Unsupported function definition", vim.log.levels.WARN)
		return
	end

	local scope = enclosing_scope(function_node)
	local member_order = scope and scope_function_order(scope, bufnr, "") or {}

	replace_function_with_declaration(bufnr, entry.node, entry.declaration)
	vim.cmd("silent write")

	local cpp_path = header_to_cpp_path(path)
	local include_line = header_include_line(path)
	local appended, reordered = sync_cpp_definitions(cpp_path, include_line, { entry }, namespace_parts, member_order)
	local name_node = resolve_function_name_node(get_field_child(function_node, "declarator"))
	local function_name = name_node and trim(get_node_text(name_node, bufnr)) or ""

	notify(string.format(
		"Extracted %s; %s",
		function_name ~= "" and function_name or "function definition",
		sync_summary(appended, reordered, cpp_path)
	))
end

function M.extract_current_class()
	local bufnr = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(bufnr)

	if path == "" or not is_header(path) then
		notify("Run this command from a C++ header buffer", vim.log.levels.ERROR)
		return
	end

	local tree = get_cpp_parser_tree(bufnr)
	if not tree then return end
	local root = tree:root()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1
	local col = cursor[2]
	local class_node = find_enclosing_class(root, row, col)

	if not class_node then
		notify("Place the cursor inside the target class", vim.log.levels.ERROR)
		return
	end

	local functions = collect_inline_member_functions(class_node)
	extract_class_functions(functions, class_node, bufnr, path)
end

function M.extract_current_function()
	local bufnr = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(bufnr)

	if path == "" or not is_header(path) then
		notify("Run this command from a C++ header buffer", vim.log.levels.ERROR)
		return
	end

	local tree = get_cpp_parser_tree(bufnr)
	if not tree then return end
	local root = tree:root()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1
	local col = cursor[2]
	local function_node = find_enclosing_function(root, row, col)
	if not function_node then
		notify("Place the cursor inside the function definition to extract", vim.log.levels.ERROR)
		return
	end

	if has_template_ancestor(function_node) then
		notify("Template function definitions should stay in the header", vim.log.levels.WARN)
		return
	end

	local class_node = find_containing_class(function_node)
	if class_node then
		extract_class_functions({ function_node }, class_node, bufnr, path)
		return
	end

	extract_namespace_function(function_node, bufnr, path)
end

function M.setup()
	vim.api.nvim_create_user_command("CppExtractDefinitions", function()
		M.extract_current_class()
	end, {
		desc = "Extract inline C++ member definitions from the current class into a .cpp file",
	})

	vim.api.nvim_create_user_command("CppExtractFunctionDefinition", function()
		M.extract_current_function()
	end, {
		desc = "Extract the current C++ function definition into a .cpp file",
	})
end

return M
