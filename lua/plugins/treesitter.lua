-- treesitter: highlighting, indenting, textobjects

return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		require("nvim-treesitter.install").compilers = { "clang", "gcc" }
		local configs = require("nvim-treesitter.configs")
		configs.setup({
			ensure_installed = { "python", "c", "cpp", "lua" },
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						-- vaf to select current func. visually
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},
			},
		})

		-- Enable Tree-sitter based folding
		-- zf  : Manually create a fold at the cursor
		-- zo  : Open fold under the cursor
		-- zc  : Close fold under the cursor
		-- zr  : Open all folds
		-- zm  : Close all folds
		-- zM  : Close all folds globally
		-- zR  : Open all folds globally
		vim.opt.foldmethod = 'expr'
		vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

		-- Optional: Start with folds open or closed
		vim.opt.foldlevel = 99 -- Ensure folds are open by default
		vim.opt.foldenable = true
	end,
}
