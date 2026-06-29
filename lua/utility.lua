vim.pack.add({
  "https://github.com/windwp/nvim-autopairs",   -- auto pairs
  "https://github.com/folke/todo-comments.nvim", -- highlight TODO/INFO/WARN comments
  "https://github.com/folke/which-key.nvim"
}, { confirm = false })

require("nvim-autopairs").setup()
require("todo-comments").setup()
require("which-key").setup({
  spec = {
    { "<leader>s", group = "[S]earch", icon = { icon = "", color = "green", }, },
  }
})

