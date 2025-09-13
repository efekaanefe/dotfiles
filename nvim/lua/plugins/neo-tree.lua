-- neo-tree: file explorer tree

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	config = function()

        -- Open Neo-tree on the right by default
        require("neo-tree").setup({
            window = {
                position = "right",  -- sidebar on the right
                width = 40,          -- optional: width of the sidebar
            },
            filesystem = {
                follow_current_file = true,  -- follow current file
            },
        })
		vim.keymap.set("n", "<C-t>", ":Neotree <CR>", {})
	end,
}
