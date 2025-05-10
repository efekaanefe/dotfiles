return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    -- your configuration comes here
  },
  config = function(_, opts)
    require("todo-comments").setup(opts)

    -- Keymap: <leader>td to open TodoQuickFix
    vim.keymap.set("n", "<leader>td", "<cmd>TodoTelescope<CR>", { desc = "Show TODOs in QuickFix" })
  end
}

