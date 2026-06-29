-- set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- enable true color support
vim.opt.termguicolors = true
-- make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true
-- enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"
-- don't show the mode, since it's already in the status line
vim.opt.showmode = false
-- sync clipboard between OS and Neovim.
vim.opt.clipboard = "unnamedplus"
-- enable break indent
vim.opt.breakindent = true
-- save undo history
vim.opt.undofile = true
-- case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- keep signcolumn on by default
vim.opt.signcolumn = "yes"
-- decrease update time
vim.opt.updatetime = 250
-- decrease mapped sequence wait time
-- displays which-key popup sooner
vim.opt.timeoutlen = 300
-- configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true
-- sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", }
-- preview substitutions live, as you type!
vim.opt.inccommand = "split"
-- show which line your cursor is on
vim.opt.cursorline = true
-- set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
-- enable line wrapping
vim.opt.wrap = true
-- enable concealing for obsidian.nvim syntax features
vim.opt.conceallevel = 2

-- formatting
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.textwidth = 80

vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  virtual_text = true, -- show inline diagnostics
})

-- clear search highlights with <Esc>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

require("theme-kanagawa")
require("treesitter")
require("blink")
require("lspconfig")
require("fzf")
require("statusline")
require("utility")
require("obsidian-plugin")
require("linting")

-- uncomment to enable automatic plugin updates
-- vim.pack.update()
