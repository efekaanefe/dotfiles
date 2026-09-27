-- Language server protocol
-- Everything this config depends on is listed here so a fresh machine installs it
-- automatically; check progress with :Mason.

-- lspconfig server name -> mason package name
local SERVERS = {
	lua_ls = "lua-language-server",
	pyright = "pyright",
	clangd = "clangd",
}

-- Mason packages that are not language servers (clang_format is used by none-ls)
local TOOLS = { "clang-format" }

-- mason-lspconfig's own `ensure_installed` silently does nothing when the registry has
-- not been downloaded yet, which is exactly the fresh-machine case, so the installs run
-- from the refresh callback instead.
local function install_missing_packages()
	local registry = require("mason-registry")

	registry.refresh(function()
		local packages = vim.list_extend(vim.tbl_values(SERVERS), TOOLS)

		vim.iter(packages):each(function(name)
			local ok, package = pcall(registry.get_package, name)
			if ok and not package:is_installed() then
				package:install()
			end
		end)
	end)
end

return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
			install_missing_packages()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		dependencies = { "williamboman/mason.nvim" }, -- mason must be set up first
		opts = {
			ensure_installed = vim.tbl_keys(SERVERS),
			automatic_installation = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {
						format = {
							enable = true,
							defaultConfig = {
								indent_style = "space",
								indent_size = "4",
							},
						},
					},
				},
			})

			lspconfig.pyright.setup({
				capabilities = capabilities,
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})
			-- Note: Pyright itself does not handle formatting; use Black, yapf, or autopep8 via null-ls if needed.

			lspconfig.clangd.setup({
				capabilities = capabilities,
				-- clangd gets formatting from .clang-format file. Optionally set one up in your project directory or home:
				-- Example ~/.clang-format:
				-- BasedOnStyle: LLVM
				-- IndentWidth: 4
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
			vim.keymap.set("n", "<leader>f", function()
				vim.lsp.buf.format({ async = true })
			end, {})
            vim.keymap.set("n", "<leader>hs", "<cmd>ClangdSwitchSourceHeader<CR>", {})

			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = false,
				update_in_insert = false,
			})
		end,
	},
}
