local M = {}

local function drawCheckBox(bool)
  return bool and "☒" or "☐"
end

local open = io.open
local function read_file(path)
  local file = open(path, "r") -- r read mode and b binary mode
  if not file then return nil end
  local content = file:read "*a" -- *a or *all reads the whole file
  file:close()
  return content
end

local function write_file(path, content)
  local file = open(path, "w")
  if not file then return nil end
  file:write(content)
  file:close()
  return content
end

M.writeSettings = function(game)
  local settingsFilePath = vim.fn.stdpath("data") .. "/sudoku-nvim-settings.json";

  local safeFile = {
    viewState = game.viewState,
    settings = game.settings,
  }

  write_file(settingsFilePath, vim.json.encode(safeFile))
end

M.readSettings = function(game)

  local settingsFilePath = vim.fn.stdpath("data") .. "/sudoku-nvim-settings.json";
  local content = read_file(settingsFilePath);
  if not content then
    return
  end

  local safeFile = vim.json.decode(content);

  if safeFile == nil or safeFile == vim.NIL then
    return
  end

  local settings = safeFile.settings;
  if settings ~= nil then
    game.settings.showNumbersLeft = settings.showNumbersLeft and true or false;
    game.settings.showCandidates = settings.showCandidates and true or false;
    game.settings.highlight.enabled = settings.highlight.enabled and true or false;
    game.settings.highlight.row = settings.highlight.row and true or false;
    game.settings.highlight.column = settings.highlight.column and true or false;
    game.settings.highlight.square = settings.highlight.square and true or false;
    game.settings.highlight.errors = settings.highlight.errors and true or false;
    game.settings.highlight.sameNumber = settings.highlight.sameNumber and true or false;
    game.settings.difficulty = settings.difficulty and settings.difficulty or 1;
  end

  local viewState = safeFile.viewState;
  if viewState then
    game.viewState = safeFile.viewState;
  end

end



M.drawSettings = function(game)

  local settings = game.settings;
  local high = settings.highlight;

  return {
    "(press [x] to toggle)",
    "Difficulty",
    "   " .. drawCheckBox(settings.difficulty == 1) .. " Easy",
    "   " .. drawCheckBox(settings.difficulty == 2) .. " Medium",
    "   " .. drawCheckBox(settings.difficulty == 3) .. " Hard",
    drawCheckBox(settings.showNumbersLeft) .. " Show which numbers are left",
    drawCheckBox(settings.showCandidates) .. " Show candidates for a cell",
    drawCheckBox(high.enabled) .. " Highlighting",
    "   " .. drawCheckBox(high.row) .. " Row",
    "   " .. drawCheckBox(high.column) .. " Column",
    "   " .. drawCheckBox(high.square) .. " Square",
    "   " .. drawCheckBox(high.errors) .. " Errors",
    "   " .. drawCheckBox(high.sameNumber) .. " Same Number",
  }
end

M.handleToggleSetting = function(game)

  local y = vim.fn.line(".")

  if y < 15 then
    return
  end

  if y == 15 then
    game.settings.difficulty = 1 + (game.settings.difficulty + 1) % 3;
  end

  if y == 16 then
    game.settings.difficulty = 1;
  end
  if y == 17 then
    game.settings.difficulty = 2;
  end
  if y == 18 then
    game.settings.difficulty = 3;
  end

  if y == 19 then
    game.settings.showNumbersLeft = not game.settings.showNumbersLeft
  end

  if y == 20 then
    game.settings.showCandidates = not game.settings.showCandidates
  end

  if y == 21 then
    game.settings.highlight.enabled = not game.settings.highlight.enabled
  end

  if y == 22 then
    game.settings.highlight.enabled = true
    game.settings.highlight.row = not game.settings.highlight.row
  end

  if y == 23 then
    game.settings.highlight.enabled = true
    game.settings.highlight.column = not game.settings.highlight.column
  end

  if y == 24 then
    game.settings.highlight.enabled = true
    game.settings.highlight.square = not game.settings.highlight.square
  end

  if y == 25 then
    game.settings.highlight.enabled = true
    game.settings.highlight.errors = not game.settings.highlight.errors
  end

  if y == 26 then
    game.settings.highlight.enabled = true
    game.settings.highlight.sameNumber = not game.settings.highlight.sameNumber
  end

  M.writeSettings(game)
end

return M
