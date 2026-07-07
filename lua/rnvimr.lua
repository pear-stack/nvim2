vim.pack.add({ "https://github.com/kevinhwang91/rnvimr" }, { confirm = false })
vim.cmd("packadd rnvimr")

-- replace netrw's open-directory behavior with ranger
vim.g.rnvimr_ex_enable = 1

-- sync ranger's cwd with neovim's
vim.g.rnvimr_ranger_cmd = { "ranger", "--cmd=set show_hidden=true" }

vim.keymap.set("n", "<leader>rr", "<cmd>RnvimrToggle<CR>", { desc = "[R]anger toggle" })
vim.keymap.set("t", "<M-o>",      "<cmd>RnvimrToggle<CR>", { desc = "Ranger toggle (terminal)" })
