return {
    {
        "nvim-telescope/telescope.nvim",
        -- 0.1.5 highlighted previews through nvim-treesitter's old module API, which the
        -- main branch removed; 0.2.x uses Neovim's own vim.treesitter instead.
        tag = "v0.2.2",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
        },
        config = function()
            local telescope = require("telescope")
            local builtin = require("telescope.builtin")

            -- Core keymaps
            vim.keymap.set("n", "<C-p>", builtin.find_files, {})
            vim.keymap.set("n", "<C-f>", builtin.live_grep, {})

            vim.keymap.set("n", "<leader>ds", function()
                builtin.lsp_document_symbols({
                    symbol_width = 50,
                    show_line = false,
                })
            end, {})

            -- 🔪 Harpoon deletion from Telescope
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            local harpoon_mark = require("harpoon.mark")

            -- One setup call only: each one replaces the previous config, so splitting
            -- the extensions across two calls silently dropped the first one.
            telescope.setup({
                extensions = {
                    harpoon = {
                        mappings = {
                            i = {
                                ["<C-d>"] = function(prompt_bufnr)
                                    local entry = action_state.get_selected_entry()
                                    actions.close(prompt_bufnr)
                                    harpoon_mark.rm_file(entry.value)
                                end,
                            },
                        },
                    },
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                },
            })

            telescope.load_extension("harpoon")
            telescope.load_extension("ui-select")
        end,
    },
}

