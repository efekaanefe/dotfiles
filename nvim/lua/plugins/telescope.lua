return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" },
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
                },
            })

            telescope.load_extension("harpoon")
        end,
    },

    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                },
            })
            require("telescope").load_extension("ui-select")
        end,
    },
}

