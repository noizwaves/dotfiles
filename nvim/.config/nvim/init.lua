-- Disable netrw so fugitive's :GBrowse uses vim.ui.open instead of the
-- broken netrw#BrowseX path in Neovim 0.10+
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Leader must be set before lazy.nvim loads so plugin-defined mappings see it
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

vim.opt.hidden = true

vim.opt.incsearch = true

vim.opt.list = true
vim.opt.listchars = { trail = "•" }

vim.opt.scrolloff = 4
vim.opt.signcolumn = "yes"

vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.opt.autoread = true
vim.opt.updatetime = 250

vim.opt.spelllang = "en_us"
vim.opt.spellsuggest = "best,9"

-- Bootstrap lazy.nvim and load plugin specs
require("config.lazy")

-- Colorscheme (set after lazy has loaded dracula)
vim.g.dracula_colorterm = 0
vim.cmd.colorscheme("dracula")

-- Load keymaps and autocmds
require("config.keymaps")
require("config.autocmds")
