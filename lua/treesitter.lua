vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" }, { confirm = false })
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(event)
    if event.data.kind == 'update' and event.data.spec.name == 'nvim-treesitter' then
      pcall(vim.cmd, 'TSUpdate')
    end
  end,
})

local status_ok, ts_configs = pcall(require, "nvim-treesitter.configs")

if status_ok then
  -- Setup and ensure your desired parsers are installed
  ts_configs.setup({
    ensure_installed = { 
      'java', 'c', 'lua', 'vim', 'vimdoc', 'query', 'elixir', 
      'heex', 'javascript', 'typescript', 'html', 'yaml',
      'bitbake',
    },
    highlight = {
        enable = true,
    },
  })

  -- Apply your custom FileType logic
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 
      'java', 'c', 'lua', 'vim', 'vimdoc', 'query', 'elixir', 
      'heex', 'javascript', 'typescript', 'html', 'yaml',
      'bitbake',
    },
    callback = function()
      -- syntax highlighting, provided by Neovim
      vim.treesitter.start()
      
      -- folds, provided by Neovim (I don't like folds)
      -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      -- vim.wo.foldmethod = 'expr'
      
      -- indentation, provided by nvim-treesitter
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end
