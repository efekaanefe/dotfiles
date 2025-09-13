return {
    'AckslD/muren.nvim',
    config = true,

    vim.keymap.set(
        'n',                      -- Mode: 'n' for normal
        '<leader>fr',               -- Keybinding
        ':MurenFresh<CR>',          -- Command to run
        { noremap = true, silent = true, desc = "Muren: Find and Replace" }
    )
}

