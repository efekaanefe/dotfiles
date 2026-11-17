-- <leader>bb opens :Compile with a command detected from the project around the current
-- file, and runs it in that project's root:
--   build.sh / run.sh -> ./run.sh simulation (or ./build.sh simulation)
--   CMakeLists.txt    -> cmake into ./build, then ./build/<add_executable name>
--   a lone C/C++ file -> compile and run that file

-- The topmost CMakeLists.txt is the project; nested ones belong to subdirectories.
local function cmake_root()
    local found = vim.fs.find("CMakeLists.txt", { upward = true, path = vim.fn.expand("%:p:h"), limit = math.huge })
    return found[#found] and vim.fs.dirname(found[#found])
end

local function cmake_executable(root)
    local text = table.concat(vim.fn.readfile(root .. "/CMakeLists.txt"), "\n")
    local name = text:match("add_executable%s*%(%s*([^%s%)]+)")
    if name == "${PROJECT_NAME}" then
        name = text:match("project%s*%(%s*([^%s%)]+)")
    end
    return name
end

local function script_command(root)
    local script = vim.uv.fs_stat(root .. "/run.sh") and "run.sh" or "build.sh"
    return "./" .. script .. " simulation"
end

local function cmake_command(root)
    -- The symlink gives clangd the compile database at the project root.
    local command = "cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build"
        .. " && ln -sf build/compile_commands.json ."
    local executable = cmake_executable(root)
    if executable then
        command = command .. " && ./build/" .. executable
    end
    return command
end

local function single_file_command(filetype)
    local compiler = filetype == "c" and "gcc -std=c17" or "g++ -std=c++20"
    local file = vim.fn.expand("%:t")
    local output = vim.fn.expand("%:t:r")
    return string.format("%s -Wall -Wextra -g %s -o %s && ./%s", compiler, file, output, output)
end

-- Returns the project root and its command, or nil when nothing matches.
local function detect_project(filetype)
    local scripts_root = vim.fs.root(0, { "build.sh", "run.sh" })
    if scripts_root then
        return scripts_root, script_command(scripts_root)
    end

    local root = cmake_root()
    if root then
        return root, cmake_command(root)
    end

    if filetype == "c" or filetype == "cpp" then
        return vim.fn.expand("%:p:h"), single_file_command(filetype)
    end
end

local function default_command(filetype)
    local root, command = detect_project(filetype)
    if not root then
        return "make -k "
    end
    -- compile-mode runs the next command here instead of in :pwd.
    vim.g.compilation_directory = root
    return command
end

-- :Compile would offer the last command; clearing it makes the prompt detect again.
local function compile_detected()
    vim.g.compile_command = nil
    vim.cmd("Compile")
end

-- Emacs-style n/p in the output buffer only; everywhere else n/p keep their meaning.
local function set_output_keymaps(event)
    local opts = { buffer = event.buf, silent = true }
    vim.keymap.set("n", "n", "<cmd>CompileNextError<CR>", opts)
    vim.keymap.set("n", "p", "<cmd>CompilePrevError<CR>", opts)
end

return {
    {
        "ej-shafran/compile-mode.nvim",
        version = "^5.0.0",
        dependencies = { "nvim-lua/plenary.nvim" },
        lazy = false,
        keys = {
            { "<leader>bb", compile_detected, desc = "Compile (command detected from project)" },
            { "<leader>br", "<cmd>Recompile<CR>", desc = "Recompile last command" },
        },
        config = function()
            vim.g.compile_mode = {
                -- blink.cmp breaks <Tab> completion in the :Compile prompt without this.
                input_word_completion = true,
                default_command = default_command,
            }
            vim.api.nvim_create_autocmd("FileType", { pattern = "compilation", callback = set_output_keymaps })
        end,
    },
}
