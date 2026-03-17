

-- package.path = package.path .. ";" .. vim.fn.expand("~/.luarocks/share/lua/5.1/?.lua")
-- package.cpath = package.cpath .. ";" .. vim.fn.expand("~/.luarocks/lib/lua/5.1/?.so")

-- ==========================================================================
-- init.lua — bare neovim, no plugins
-- ==========================================================================
-- Goal: understand everything here before adding a single plugin.
-- Run :help <option> on anything that's unclear.

-- --------------------------------------------------------------------------
-- Leader key (set this BEFORE any mappings that use it)
-- --------------------------------------------------------------------------
-- Space is the most ergonomic leader. We set it early so every
-- vim.keymap.set("n", "<leader>...", ...) that follows picks it up.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- --------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------
local opt = vim.opt

-- Line numbers: absolute + relative. Absolute on the cursor line,
-- relative everywhere else. This makes motion counts (e.g. 14j) trivial.
opt.number = true
opt.relativenumber = true

-- Tabs & indentation
-- These interact in non-obvious ways. The short version:
--   tabstop     = how wide a literal \t displays
--   shiftwidth  = how many columns >> and auto-indent use
--   expandtab   = insert spaces instead of \t
--   softtabstop  = how many columns <Tab> key inserts (follows shiftwidth if -1)
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = -1 -- use shiftwidth value
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true -- case-insensitive by default...
opt.smartcase = true  -- ...unless you type a capital letter
opt.hlsearch = true   -- highlight matches (we map <Esc> to clear below)
opt.incsearch = true  -- show matches as you type

-- Appearance
opt.termguicolors = true  -- 24-bit color (your terminal needs to support this)
opt.signcolumn = "yes"    -- always show — prevents layout shift from diagnostics/git
opt.cursorline = true     -- highlight current line
opt.scrolloff = 8         -- keep 8 lines visible above/below cursor
opt.sidescrolloff = 8
opt.wrap = false          -- no line wrapping (toggle with <leader>tw below)
opt.colorcolumn = "80"    -- subtle ruler at 80 chars

-- Splits: open new splits to the right and below (matches spatial intuition)
opt.splitright = true
opt.splitbelow = true

-- Undo: persist undo history across sessions. Neovim stores these in
-- ~/.local/state/nvim/undo/ by default. This is one of the most
-- underappreciated built-in features.
opt.undofile = true

-- Misc
opt.mouse = "a"           -- mouse works in all modes (useful, not shameful)
opt.clipboard = "unnamedplus" -- yank/paste uses system clipboard
opt.updatetime = 250      -- faster CursorHold events (useful for LSP later)
opt.timeoutlen = 300      -- ms to wait for mapped sequence to complete
opt.completeopt = { "menu", "menuone", "noselect" } -- sane completion menu
opt.inccommand = "split"  -- live preview of :s substitutions
opt.list = true           -- show whitespace characters
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Disable some built-in plugins we'll never use (tiny startup speedup)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tarPlugin = 1

-- --------------------------------------------------------------------------
-- Keymaps
-- --------------------------------------------------------------------------
local map = vim.keymap.set

-- Clear search highlights with Escape
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Better window navigation (Ctrl+hjkl instead of Ctrl+W then hjkl)
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows with Ctrl+arrows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Grow window vertically" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shrink window vertically" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Shrink window horizontally" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Grow window horizontally" })

-- Move lines up/down in visual mode (and re-select after)
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- J (join lines) without moving cursor
map("n", "J", "mzJ`z", { desc = "Join lines (cursor stays)" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- Keep cursor centered when jumping between search matches
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })

-- Paste over selection without yanking the replaced text
-- (otherwise pasting over something pollutes your register)
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking replaced text" })

-- Delete to void register (don't pollute clipboard)
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to void register" })

-- Quick save
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- Quick quit
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Toggle line wrap
map("n", "<leader>tw", function()
    vim.opt.wrap = not vim.opt.wrap:get()
    print("Wrap: " .. tostring(vim.opt.wrap:get()))
end, { desc = "Toggle line wrap" })

-- Open file explorer (netrw is disabled above, but the built-in
-- vim.cmd("Explore") still works via :Ex — or just use this until
-- you add a file tree plugin later)
map("n", "<leader>e", "<cmd>Explore<CR>", { desc = "File explorer" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Diagnostic keymaps (these work without any LSP — Neovim has a
-- built-in diagnostic framework)
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- --------------------------------------------------------------------------
-- Autocommands
-- --------------------------------------------------------------------------
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight text on yank (briefly flash what you just yanked)
autocmd("TextYankPost", {
    group = augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank({ timeout = 200 })
    end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
    group = augroup("trim-whitespace", { clear = true }),
    pattern = "*",
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[%s/\s\+$//e]])
        vim.api.nvim_win_set_cursor(0, pos)
    end,
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- Return to last edit position when opening a file
autocmd("BufReadPost", {
    group = augroup("restore-cursor", { clear = true }),
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local line_count = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Auto-resize splits when terminal window is resized
autocmd("VimResized", {
    group = augroup("auto-resize", { clear = true }),
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- --------------------------------------------------------------------------
-- That's it. Use this for a few days. When you feel a specific pain
-- point ("I wish I could fuzzy-find files"), that's when you add
-- a plugin to solve it. Not before.
--
-- Next steps when you're ready:
--   1. Add lazy.nvim (plugin manager)
--   2. Add treesitter (better syntax highlighting)
--   3. Add LSP (code intelligence)
--   4. Add a fuzzy finder (telescope or fzf-lua)
-- --------------------------------------------------------------------------

vim.o.relativenumber = true         -- relative line numbers
-- vim.o.cc = 80                  -- 80 char gutter
vim.o.cursorline = true
vim.o.ttyfast = true

vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

vim.opt.textwidth = 80

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },
  { import = "plugins" },
  {
    dir = "~/urb/vere-rs/shrine.nvim",
    lazy = false,
    dev = true,
    build = "luarocks install lua-protobuf",
    config = function()
      require('shrine').setup()
    end,
  },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
