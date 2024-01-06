return {
{
	"alec-gibson/nvim-tetris",
	event = "VeryLazy",
},
{
	"ThePrimeagen/vim-be-good",
	event = "VeryLazy",
},
{
	"seandewar/nvimesweeper",
	event = "VeryLazy",
},
{
	"zyedidia/vim-snake",
	event = "VeryLazy",
},
{
	"jim-fx/sudoku.nvim",
	cmd = "Sudoku",
	config = function()
		require("sudoku").setup({

})
	end
},
{
	"seandewar/killersheep.nvim",
	event = "VeryLazy",
},
{
	"luk400/vim-lichess", -- not working when run :LichessFindGame
	event = "VeryLazy",
	opts = {},
	config = function (_, opts)
		vim.g.python_cmd = "python"
		vim.g.lichess_api_token = "lip_ihbKrQgtStfEldeycHXt";
	end,
},
}


