require "nvchad.mappings"
local tmux_nav = require('nvim-tmux-navigation')

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<C-h>", tmux_nav.NvimTmuxNavigateLeft)
map("n", "<C-j>", tmux_nav.NvimTmuxNavigateDown)
map("n", "<C-k>", tmux_nav.NvimTmuxNavigateUp)
map("n", "<C-l>", tmux_nav.NvimTmuxNavigateRight)

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
