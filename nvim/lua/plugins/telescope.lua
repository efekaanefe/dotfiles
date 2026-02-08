-- telescope: file (+keyword) search

return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<C-p>", builtin.find_files, {}) --ctrl+p to find files
			vim.keymap.set("n", "<C-f>", builtin.live_grep, {}) -- ctrl+f to find keywords

            vim.keymap.set("n", "<leader>ds", function()
              require("telescope.builtin").lsp_document_symbols({
                symbol_width = 50,
                show_line = false,
              })
            end, {}) -- space+ds to fzf symbols

             
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
