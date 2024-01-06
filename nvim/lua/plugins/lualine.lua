-- Statusline

return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
	config = function()
		require("lualine").setup({
		options = {
			--theme = "gruvbox_dark"
			--theme = "horizon"
			theme = "onedark"
			--theme = "solarized_dark"
		}
	})
	end
}
