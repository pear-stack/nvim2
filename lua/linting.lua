vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" }, { confirm = false })

require("lint").linters_by_ft = {
  bitbake = { "oelint-adv" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
