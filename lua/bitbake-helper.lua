local M = {}

local root_markers = { ".git", "build/conf/local.conf", "build/conf/bblayers.conf" }

function M.find_root()
  local dir = vim.fn.expand("%:p:h")
  while dir ~= "/" do
    for _, marker in ipairs(root_markers) do
      local path = dir .. "/" .. marker
      if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
        return dir
      end
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return vim.fn.expand("%:p:h")
end

function M.find_layers(root)
  local layers = {}
  for _, path in ipairs({
    root .. "/layers",
    root .. "/meta",
    root .. "/meta-*",
  }) do
    local matches = vim.fn.glob(path, false, true)
    if type(matches) == "string" then
      table.insert(layers, matches)
    else
      for _, m in ipairs(matches) do
        table.insert(layers, m)
      end
    end
  end
  local bblayers = root .. "/build/conf/bblayers.conf"
  if vim.fn.filereadable(bblayers) == 1 then
    for line in io.lines(bblayers) do
      local layer_path = line:match('BBLAYERS.-"(.+)"')
      if layer_path and vim.fn.isdirectory(layer_path) == 1 then
        table.insert(layers, layer_path)
      end
    end
  end
  table.insert(layers, root)
  return layers
end

function M.find_inherit_class(word, layers)
  for _, sub in ipairs({ "classes", "classes-recipe", "classes-global" }) do
    for _, layer in ipairs(layers) do
      local path = layer .. "/" .. sub .. "/" .. word .. ".bbclass"
      if vim.fn.filereadable(path) == 1 then
        return path
      end
    end
  end
end

function M.find_required_file(word, recipe_dir, layers)
  local candidates = {
    recipe_dir .. "/" .. word,
    recipe_dir .. "/" .. word .. ".inc",
    recipe_dir .. "/" .. word .. ".bb",
  }
  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  if not word:match("%.") and not word:match("/") then
    for _, layer in ipairs(layers) do
      local results = vim.fn.glob(layer .. "/**/" .. word .. ".{inc,bb,bbclass}", false, true)
      if type(results) ~= "table" then
        results = { results }
      end
      if #results > 0 then
        return results[1]
      end
    end
  else
    for _, layer in ipairs(layers) do
      local path = layer .. "/" .. word
      if vim.fn.filereadable(path) == 1 then
        return path
      end
    end
    for _, layer in ipairs(layers) do
      local results = vim.fn.glob(layer .. "/**/" .. word, false, true)
      if type(results) ~= "table" then
        results = { results }
      end
      if #results > 0 then
        return results[1]
      end
    end
  end
end

function M.find_patch_file(word, recipe_dir)
  local candidates = {
    recipe_dir .. "/files/" .. word,
    recipe_dir .. "/" .. word,
  }
  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  local recipe_name = vim.fn.expand("%:t:r")
  local bpn = recipe_name:gsub("_.*$", "")
  local pv = recipe_name:match("_(.+)$")
  if bpn then
    table.insert(candidates, recipe_dir .. "/" .. bpn .. "/" .. word)
    if pv then
      table.insert(candidates, recipe_dir .. "/" .. bpn .. "-" .. pv .. "/" .. word)
    end
  end
  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  local results = vim.fn.glob(recipe_dir .. "/**/" .. word, false, true)
  if type(results) == "table" and #results > 0 then
    return results[1]
  elseif type(results) == "string" and results ~= "" then
    return results
  end
end

local function find_by_line_analysis(line, word, recipe_dir, layers)
  word = word or vim.fn.expand("<cword>")
  line = line or vim.fn.getline(".")
  local col = vim.fn.col(".") - 1
  local before = line:sub(1, col)

  if before:match("inherit%s+$") or before:match("inherit%s+%w+%s+$") or line:match("^inherit%s") then
    local class_file = M.find_inherit_class(word, layers)
    if class_file then
      vim.cmd("edit " .. vim.fn.fnameescape(class_file))
      return true
    end
  end

  if before:match("require%s+$") or before:match("require%s+%S+%s+$") or line:match("^require%s") then
    local found = M.find_required_file(word, recipe_dir, layers)
    if found then
      vim.cmd("edit " .. vim.fn.fnameescape(found))
      return true
    end
  end

  if before:match("include%s+$") or before:match("include%s+%S+%s+$") or line:match("^include%s") then
    local found = M.find_required_file(word, recipe_dir, layers)
    if found then
      vim.cmd("edit " .. vim.fn.fnameescape(found))
      return true
    end
  end

  if line:match("file://") then
    local file_url = line:match("file://([%w%._/-]+)")
    local name = file_url and file_url:match("([^/]+)$") or word
    local patch_file = M.find_patch_file(name, recipe_dir)
    if patch_file then
      vim.cmd("edit " .. vim.fn.fnameescape(patch_file))
      return true
    end
  end
end

function M.go_to_definition()
  local root = M.find_root()
  if not root then
    return
  end

  local recipe_dir = vim.fn.expand("%:p:h")
  local layers = M.find_layers(root)

  if find_by_line_analysis(nil, nil, recipe_dir, layers) then
    return
  end

  local ok, _ = pcall(vim.lsp.buf.definition)
  if not ok then
    vim.notify("No definition found", vim.log.levels.WARN)
  end
end

local group = vim.api.nvim_create_augroup("bitbake_helper", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "bitbake",
  callback = function()
    vim.keymap.set("n", "grd", M.go_to_definition, { buffer = true, desc = "BitBake go to definition" })
    vim.keymap.set("n", "gD", M.go_to_definition, { buffer = true, desc = "BitBake go to definition" })
  end,
})

return M
