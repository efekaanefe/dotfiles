return {
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = true,
		opts = opts,
		config = function()
			vim.o.background = "dark" -- or "light" for light mode
			vim.cmd("colorscheme gruvbox")
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
	},
	{
		"olimorris/onedarkpro.nvim",
		priority = 1000, -- Ensure it loads first
	},
}
