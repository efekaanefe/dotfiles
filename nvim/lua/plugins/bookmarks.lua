return {
    {
        'tomasky/bookmarks.nvim',
        -- after = "telescope.nvim",
        event = "VimEnter",
        config = function()
            require('bookmarks').setup {
                -- sign_priority = 8,  --set bookmark sign priority to cover other sign
                save_file = vim.fn.expand "$HOME/.bookmarks", -- bookmarks save file path
                keywords = {
                    ["@t"] = "☑️ ", -- mark annotation startswith @t ,signs this icon as `Todo`
                    ["@w"] = "⚠️ ", -- mark annotation startswith @w ,signs this icon as `Warn`
                    ["@f"] = "⛏ ", -- mark annotation startswith @f ,signs this icon as `Fix`
                    ["@n"] = " ", -- mark annotation startswith @n ,signs this icon as `Note`
                },
                on_attach = function(bufnr)
                    local bm = require "bookmarks"
                    local map = vim.keymap.set
                    map("n", "mm", bm.bookmark_toggle) -- add or remove bookmark at current line
                    map("n", "mi", bm.bookmark_ann)   -- add or edit mark annotation at current line
                    map("n", "mc", bm.bookmark_clean) -- clean all marks in local buffer
                    map("n", "mn", bm.bookmark_next)  -- jump to next mark in local buffer
                    map("n", "mp", bm.bookmark_prev)  -- jump to previous mark in local buffer
                    map("n", "ml", bm.bookmark_list)  -- show marked file list in quickfix window
                    map("n", "mx", bm.bookmark_clear_all) -- removes all bookmarks
                end
            }
        end
    },

    {
        "ThePrimeagen/harpoon",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
        config = function()
            require("harpoon").setup({})

            -- Telescope integration
            require("telescope").load_extension("harpoon")

            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")

            local map = vim.keymap.set
            local opts = { noremap = true, silent = true }

            -- leader + h + x → mark file
            map("n", "<leader>hx", mark.add_file, opts)

            -- leader + h + n / p → next / previous file
            map("n", "<leader>hn", ui.nav_next, opts)
            map("n", "<leader>hp", ui.nav_prev, opts)

            -- leader + h + f → list marks in Telescope
            map("n", "<leader>hf", function()
                require("telescope").extensions.harpoon.marks()

            vim.keymap.set("n", "<leader>hc", function()
                require("harpoon.mark").clear_all()
            end, { silent = true })


            vim.keymap.set("n", "<leader>hr", function()
              require("harpoon.mark").rm_file()
            end, { silent = true })

            end, opts)
        end
    }
}
