vim.cmd(":set number")
vim.cmd(":set relativenumber")
vim.cmd(":set autoindent")
vim.cmd(":set tabstop=4")
vim.cmd(":set shiftwidth=4")
vim.cmd(":set smarttab")
vim.o.expandtab = true -- Use spaces instead of tabs
-- vim.cmd(":set softtabstop=4")
vim.cmd(":set mouse=a")

vim.g.mapleader = " "

--vim.keymap.set("n", "<leader>w", ":e D:\\Python_Related<CR>")

--vim.opt.guicursor = "" -- fat cursor
vim.opt.scrolloff = 8
vim.opt.termguicolors = true

-- Remaps
-- from: https://youtu.be/w7i4amO_zaE?si=qyETAhki9H5HUMb8&t=1594
vim.keymap.set("n", "<leader>w", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>vwm", function()
require("vim-with-me").StartVimWithMe()
end)
vim.keymap.set("n", "<leader>svwm", function()
require("vim-with-me").StopVimWithMe()
end)

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]])
vim.keymap.set("n", "<leader>P", [["+P]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>");
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

vim.keymap.set("n", "<leader><leader>", function()
vim.cmd("so")
end)

-- ctrl + a to visually select everything
vim.keymap.set('n', '<C-a>', 'ggVG', { noremap = true, silent = true })

-- compile and run raylib
vim.keymap.set('n', '<leader>rl', ':term g++ src/*.cpp -Iinclude -lraylib -o sim && ./sim<CR>')
