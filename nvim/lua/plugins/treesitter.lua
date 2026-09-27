-- treesitter: highlighting, indenting, folding, textobjects
-- On the `main` branch this plugin only ships parsers and queries; the features
-- themselves come from Neovim, so each one is enabled per buffer below.

local LANGUAGES = { "python", "c", "cpp", "lua" }

-- vaf/vif select a function, vac/vic a class
local SELECT_KEYS = {
	af = "@function.outer",
	["if"] = "@function.inner",
	ac = "@class.outer",
	ic = "@class.inner",
}

local MOVE_KEYS = {
	["]f"] = { "goto_next_start", "@function.outer" },
	["[f"] = { "goto_previous_start", "@function.outer" },
	["]c"] = { "goto_next_start", "@class.outer" },
	["[c"] = { "goto_previous_start", "@class.outer" },
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- the main branch does not support lazy-loading
		build = ":TSUpdate",
		config = function()
			-- The main branch compiles parsers with the tree-sitter CLI; without it every
			-- language would report a build failure on each start. :checkhealth
			-- nvim-treesitter reports the missing CLI.
			if vim.fn.executable("tree-sitter") == 1 then
				require("nvim-treesitter").install(LANGUAGES)
			end

			-- vim.treesitter.start() turns Vim's regex syntax off, so it must not run
			-- unless treesitter can actually colour the buffer. A parser alone is not
			-- enough: the language also needs a highlights query that loads cleanly.
			-- Queries under `after/queries` (e.g. from a colorscheme) only extend a base
			-- query, so on their own they would leave the buffer nearly unhighlighted.
			local function has_treesitter_highlights(bufnr)
				local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
				if not lang or not pcall(vim.treesitter.language.add, lang) then return false end

				local query_files = vim.api.nvim_get_runtime_file("queries/" .. lang .. "/highlights.scm", true)
				local has_base_query = vim.iter(query_files):any(function(path)
					return not path:match("/after/queries/")
				end)
				if not has_base_query then return false end

				local ok, query = pcall(vim.treesitter.query.get, lang, "highlights")
				return ok and query ~= nil
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("TreesitterFeatures", { clear = true }),
				callback = function(args)
					-- Otherwise the buffer keeps Vim's own syntax and indent
					if not has_treesitter_highlights(args.buf) then return end
					if not pcall(vim.treesitter.start, args.buf) then return end

					-- zo/zc open/close the fold under the cursor, zR/zM all of them
					vim.wo[0][0].foldmethod = "expr"
					vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})

			vim.opt.foldlevel = 99 -- start with every fold open
			vim.opt.foldenable = true
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			vim.iter(SELECT_KEYS):each(function(lhs, query)
				vim.keymap.set({ "x", "o" }, lhs, function()
					select.select_textobject(query, "textobjects")
				end, { desc = "Select " .. query })
			end)

			local move = require("nvim-treesitter-textobjects.move")
			vim.iter(MOVE_KEYS):each(function(lhs, spec)
				local direction, query = spec[1], spec[2]
				vim.keymap.set({ "n", "x", "o" }, lhs, function()
					move[direction](query, "textobjects")
				end, { desc = direction .. " " .. query })
			end)
		end,
	},
}
