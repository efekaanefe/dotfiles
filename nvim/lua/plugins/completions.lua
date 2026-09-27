return {

    {
        "supermaven-inc/supermaven-nvim",
        config = function()
            require("supermaven-nvim").setup({
                keymaps = {
                    accept_suggestion = "<Tab>",
                    clear_suggestion = "<C-]>",
                    accept_word = "<C-j>",
                },
            })
        end,
    },
    -- {
    --     "monkoose/neocodeium",
    --     event = "VeryLazy",
    --     config = function()
    --         local neocodeium = require("neocodeium")
    --
    --         neocodeium.setup({
    --             -- This visually collapses multi-line suggestions into a single line
    --             -- It shows the rest only as you accept it or move down
    --             single_line = {
    --                 enabled = true,
    --             },
    --         })
    --
    --         -- Map your preferred keys
    --         vim.keymap.set("i", "<Tab>", neocodeium.accept, { noremap = true, silent = true })
    --         vim.keymap.set("i", "<C-j>", neocodeium.accept_word, { noremap = true, silent = true })
    --
    --         -- This is the key you'll use to accept just ONE line at a time
    --         vim.keymap.set("i", "<C-l>", neocodeium.accept_line, { noremap = true, silent = true })
    --
    --         -- Key to clear/reject the suggestion
    --         vim.keymap.set("i", "<C-]>", neocodeium.clear, { noremap = true, silent = true })
    --     end,
    -- },
    {
        "hrsh7th/cmp-nvim-lsp",
    },
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
    },
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require("cmp")
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" }, -- For luasnip users.
                    --{ name = "snippy" }
                }, {
                    { name = "buffer" },
                }),
            })
        end,
    },
}
