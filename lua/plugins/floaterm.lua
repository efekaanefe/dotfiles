return {
    'voldikss/vim-floaterm',
    config = function()
        -- Key mapping for running Python script
        vim.api.nvim_set_keymap(
            'n',
            '<Leader>py',
            [[<cmd>w<bar>FloatermNew --height=0.4 --width=0.9 --wintype=float --name="pcr" --disposable --position=bottom --autoclose=0 python3 %<CR>]],
            { noremap = true, silent = true }
        )

        -- Key mapping for opening a new Floaterm
        vim.api.nvim_set_keymap(
            'n',
            '<leader>ft',
            ':FloatermNew<CR>',
            { noremap = true, silent = true }
        )
    end
}

