vim.pack.add({ "https://github.com/epwalsh/obsidian.nvim" }, { confirm = false })
require("obsidian").setup({
  workspaces = {
    {
      name = "personal",
      path = "~/samba/notes",
    },
  },
})
