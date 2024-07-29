-- Language server protocol
return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"pyright",
					--"jedi_language_server",
					"clangd",
					--"arduino_language_server",
					--"cmake", "bashls",
					--"tsserver", , "omnisharp"
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			--lspconfig.jedi_language_server.setup({
			lspconfig.pyright.setup({
				capabilities = capabilities,
			})
			lspconfig.clangd.setup({
				capabilities = capabilities,
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {}) -- display hover information
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {}) -- go to definition
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {}) --
		end,
	},
}
