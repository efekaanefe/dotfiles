return {
    -- {
    --     -- Not a completion plugin (chartoggle + file tree). Disabled because its keys
    --     -- override `,` (repeat f/t backwards), <C-e> and <leader>e.
    --     'saghen/blink.nvim',
    --     build = 'cargo build --release', -- for delimiters
    --     keys = {
    --         -- chartoggle
    --         {
    --             '<C-;>',
    --             function()
    --                 require('blink.chartoggle').toggle_char_eol(';')
    --             end,
    --             mode = { 'n', 'v' },
    --             desc = 'Toggle ; at eol',
    --         },
    --         {
    --             ',',
    --             function()
    --                 require('blink.chartoggle').toggle_char_eol(',')
    --             end,
    --             mode = { 'n', 'v' },
    --             desc = 'Toggle , at eol',
    --         },
    --
    --         -- tree
    --         { '<C-e>',     '<cmd>BlinkTree reveal<cr>',       desc = 'Reveal current file in tree' },
    --         { '<leader>E', '<cmd>BlinkTree toggle<cr>',       desc = 'Reveal current file in tree' },
    --         { '<leader>e', '<cmd>BlinkTree toggle-focus<cr>', desc = 'Toggle file tree focus' },
    --     },
    --     -- all modules handle lazy loading internally
    --     lazy = false,
    --     opts = {
    --         chartoggle = { enabled = true },
    --         tree = { enabled = true }
    --     }
    -- },

    -- {
    --     "supermaven-inc/supermaven-nvim",
    --     config = function()
    --         require("supermaven-nvim").setup({
    --             keymaps = {
    --                 accept_suggestion = "<Tab>",
    --                 clear_suggestion = "<C-]>",
    --                 accept_word = "<C-j>",
    --             },
    --         })
    --     end,
    -- },
    -- {
    --     "monkoose/neocodeium",
    --     event = "VeryLazy",
    --     config = function()
    --         local neocodeium = require("neocodeium")
    --         neocodeium.setup({
    --             -- Default server.codeium.com is dead; Windsurf moved accounts here.
    --             server = {
    --                 api_url = "https://server.self-serve.windsurf.com",
    --             },
    --             single_line = {
    --                 enabled = true,
    --             },
    --         })
    --         vim.keymap.set("i", "<Tab>", neocodeium.accept, { noremap = true, silent = true })
    --         vim.keymap.set("i", "<C-j>", neocodeium.accept_word, { noremap = true, silent = true })
    --         vim.keymap.set("i", "<C-l>", neocodeium.accept_line, { noremap = true, silent = true })
    --         vim.keymap.set("i", "<C-]>", neocodeium.clear, { noremap = true, silent = true })
    --     end,
    -- },
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },
    {
        "saghen/blink.cmp",
        version = "1.*", -- release tags ship a prebuilt fuzzy matcher, so no cargo build
        dependencies = { "L3MON4D3/LuaSnip" },
        -- Must load at startup: its plugin/ file adds completion capabilities to
        -- vim.lsp.config("*") and has to run before the language servers start.
        lazy = false,
        opts = {
            -- Same keys as the old nvim-cmp setup: <CR> accept, <C-Space> open,
            -- <C-e> close, <C-b>/<C-f> scroll docs; <Tab> jumps inside snippets.
            keymap = { preset = "enter" },
            snippets = { preset = "luasnip" },
            completion = {
                menu = { border = "rounded" },
                documentation = {
                    auto_show = true,
                    window = { border = "rounded" },
                },
            },
        },
    },
}
