local options = require "sudoku.options"
local fs      = require "sudoku.fs"
local M       = {}

---@class HighlighSettings
---@field enabled boolean
---@field row boolean
---@field column boolean
---@field square boolean
---@field errors boolean
---@field sameNumber boolean

---@class Settings
---@field showNumbersLeft boolean
---@field showCandidates boolean
---@field showInvalidBoard boolean
---@field difficulty number
---@field highlight HighlighSettings

local function drawCheckBox(bool)
  return bool and "☒" or "☐"
end

---@param game Game
M.writeSettings = function(game)

  if not options.get("persist_settings") then return end

  local saveFile = {
    viewState = game.viewState,
    settings = game.settings,
  }

  fs.write("settings.json", saveFile);
end

---@return Settings
M.readSettings = function()

  ---@type Settings
  local defaultSettings = {
    showNumbersLeft = true,
    showCandidates = false,
    showInvalidBoard = true,
    highlight = {
      enabled = true,
      row = true,
      column = true,
      square = true,
      errors = true,
      sameNumber = true
    },
    difficulty = 1
  }

  local persistSettings = options.get("persist_settings")
  if not persistSettings then
    return defaultSettings
  end

  local saveFile = fs.read("settings.json");
  if not saveFile then
    return defaultSettings
  end

  local settings = saveFile.settings;
  if settings ~= nil then
    defaultSettings.showNumbersLeft = settings.showNumbersLeft and true or false;
    defaultSettings.showCandidates = settings.showCandidates and true or false;
    defaultSettings.highlight.enabled = settings.highlight.enabled and true or false;
    defaultSettings.highlight.row = settings.highlight.row and true or false;
    defaultSettings.highlight.column = settings.highlight.column and true or false;
    defaultSettings.highlight.square = settings.highlight.square and true or false;
    defaultSettings.highlight.errors = settings.highlight.errors and true or false;
    defaultSettings.highlight.sameNumber = settings.highlight.sameNumber and true or false;
    defaultSettings.difficulty = settings.difficulty and settings.difficulty or 1;
  end

  return defaultSettings

end

---@param game Game
---@return table
M.drawSettings = function(game)

  local settings = game.settings;
  local high = settings.highlight;

  return {
    "(press [x] to toggle)",
    "Difficulty",
    "   " .. drawCheckBox(settings.difficulty == 1) .. " Easy",
    "   " .. drawCheckBox(settings.difficulty == 2) .. " Medium",
    "   " .. drawCheckBox(settings.difficulty == 3) .. " Hard",
    "   " .. drawCheckBox(settings.difficulty == 4) .. " Impossible",
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
    game.settings.difficulty = 4;
  end

  if y == 20 then
    game.settings.showNumbersLeft = not game.settings.showNumbersLeft
  end

  if y == 21 then
    game.settings.showCandidates = not game.settings.showCandidates
  end

  if y == 22 then
    game.settings.highlight.enabled = not game.settings.highlight.enabled
  end

  if y == 23 then
    game.settings.highlight.enabled = true
    game.settings.highlight.row = not game.settings.highlight.row
  end

  if y == 24 then
    game.settings.highlight.enabled = true
    game.settings.highlight.column = not game.settings.highlight.column
  end

  if y == 25 then
    game.settings.highlight.enabled = true
    game.settings.highlight.square = not game.settings.highlight.square
  end

  if y == 26 then
    game.settings.highlight.enabled = true
    game.settings.highlight.errors = not game.settings.highlight.errors
  end

  if y == 27 then
    game.settings.highlight.enabled = true
    game.settings.highlight.sameNumber = not game.settings.highlight.sameNumber
  end

  M.writeSettings(game)
end

return M
