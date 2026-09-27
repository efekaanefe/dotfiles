-- formatting, completion

return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			-- Only tools that are actually installed belong here; a missing one either
			-- fails silently or, like the broken mypy shim, reports on every buffer.
			-- Everything else is formatted by its language server (clangd, lua_ls) and
			-- type-checked by pyright.
			sources = {
				-- cpp
				null_ls.builtins.formatting.clang_format,
			},
		})
		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
