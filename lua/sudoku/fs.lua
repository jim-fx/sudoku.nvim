local settingsFilePath = vim.fn.stdpath("data") .. "/sudoku-nvim/";

local open = io.open
local function read_file(path)

  local file = open(path, "r") -- r read mode and b binary mode
  if not file then return nil end
  local content = file:read "*a" -- *a or *all reads the whole file
  file:close()

  local jsonData = vim.json.decode(content);
  if jsonData == nil or jsonData == vim.NIL then
    return nil
  end

  return jsonData
end

local function write_file(path, data)
  vim.fn.mkdir(settingsFilePath, "p");
  local file = open(path, "w")
  if not file then return nil end

  local content = vim.json.encode(data)

  file:write(content)
  file:close()
  return content
end

return {
  write = function(name, content)
    return write_file(settingsFilePath .. name, content);
  end,
  read = function(name)
    return read_file(settingsFilePath .. name);
  end
}
