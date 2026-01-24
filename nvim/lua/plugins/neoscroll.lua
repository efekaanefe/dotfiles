return {
  "karb94/neoscroll.nvim",
  config = function()
    local neoscroll = require("neoscroll")

    neoscroll.setup({})

    -- functions
    local scroll = {
      up_half   = function() neoscroll.ctrl_u({ duration = 100 }) end,
      down_half = function() neoscroll.ctrl_d({ duration = 100 }) end,
      up_full   = function() neoscroll.ctrl_b({ duration = 450 }) end,
      down_full = function() neoscroll.ctrl_f({ duration = 450 }) end,
      up_line   = function() neoscroll.scroll(-0.1, { move_cursor = false, duration = 100 }) end,
      down_line = function() neoscroll.scroll( 0.1, { move_cursor = false, duration = 100 }) end,
    }

    -- keymaps
    local keymap = {
      ["<C-u>"] = scroll.up_half,
      ["<C-d>"] = scroll.down_half,
      -- ["<C-b>"] = scroll.up_full,
      -- ["<C-f>"] = scroll.down_full,
      -- ["<C-y>"] = scroll.up_line,
      -- ["<C-e>"] = scroll.down_line,
    }

    local modes = { "n", "v", "x" }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func)
    end

    -- commands
    vim.api.nvim_create_user_command("NeoscrollUpHalf",   scroll.up_half,   {})
    vim.api.nvim_create_user_command("NeoscrollDownHalf", scroll.down_half, {})
    -- vim.api.nvim_create_user_command("NeoscrollUpFull",   scroll.up_full,   {})
    -- vim.api.nvim_create_user_command("NeoscrollDownFull", scroll.down_full, {})
    -- vim.api.nvim_create_user_command("NeoscrollUpLine",   scroll.up_line,   {})
    -- vim.api.nvim_create_user_command("NeoscrollDownLine", scroll.down_line, {})
  end,
}
