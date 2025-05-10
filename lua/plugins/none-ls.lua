-- formatting, completion

return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				-- lua
				null_ls.builtins.formatting.stylua,

				-- js
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.diagnostics.eslint_d,

				-- cpp
				null_ls.builtins.formatting.clang_format,

				--null_ls.builtins.completion.spell,
				--
				-- python
				--null_ls.builtins.formatting.pyink,
				null_ls.builtins.formatting.black,
				--null_ls.builtins.formatting.isort,
				null_ls.builtins.diagnostics.mypy, --linter
			},
		})
		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
