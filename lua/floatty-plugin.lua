vim.pack.add({ "https://github.com/ingur/floatty.nvim" }, { confirm = false })
vim.cmd("packadd floatty.nvim")

local function read_project_config()
  local path = vim.fn.getcwd() .. "/.nvim/floatty.json"
  if vim.fn.filereadable(path) == 0 then
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
  if not ok or type(decoded) ~= "table" or not decoded.build then
    vim.notify("floatty: invalid config at " .. path, vim.log.levels.WARN)
    return nil
  end

  return decoded
end

local cfg = read_project_config()

if cfg then
  local build = cfg.build
  local cwd = (cfg.cwd and cfg.cwd ~= ".") and cfg.cwd or vim.fn.getcwd()

  local est_float = require("floatty").setup({
    cmd             = build,
    cwd             = cwd,
    start_in_insert = false,
    on_open = function(_, buf)
      -- TermOpen fires after on_open; schedule stopinsert to run after any
      -- global TermOpen autocmds (e.g. from other plugins) that call startinsert
      vim.api.nvim_create_autocmd("TermOpen", {
        buffer = buf,
        once   = true,
        callback = function()
          vim.schedule(function()
            vim.cmd("stopinsert")
            vim.cmd("normal! G")
          end)
        end,
      })
    end,
    window = {
      width   = 0.4,
      height  = 0.35,
      h_align = "right",
      v_align = "top",
      border  = "rounded",
    },
  })

  vim.keymap.set("n", "<F6>", function() est_float.toggle() end, { desc = "Build project (float)" })

  vim.keymap.set("n", "<F7>", function()
    vim.cmd("split")
    vim.fn.termopen(build, { cwd = cwd })
    vim.cmd("startinsert")
  end, { desc = "Build project (split)" })
end
