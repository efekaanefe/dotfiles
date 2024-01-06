-- treesitter: highlighting and indenting

return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.install").compilers = { "clang", "gcc" }
		local configs = require("nvim-treesitter.configs")
		configs.setup({
			ensure_installed = { "python", "c", "cpp", "lua" },
			--auto_install = true,
			--sync_install = false,
			--highlight = { enable = true }, --gives error, why?
			indent = { enable = true },
		})
	end,
}
