local core = require("sudoku.core");
local ui = require("sudoku.ui");
local events = require("sudoku.events");
local settings = require("sudoku.settings");
local M = {}

local namespace = vim.api.nvim_create_namespace("jim-fx/sudoku.nvim");

---@class Game
---@field bufnr number
---@field ns number
---@field board Board
---@field boards Board[]
---@field viewState ViewState
---@field settings Settings
---@field __debug boolean

M.init = function()

  local buf = ui.setupBuffer();

  local game = {
    bufnr = buf,
    ns = namespace,
    board = nil,
    viewState = "normal",
    boards = {},
    settings = {
      showNumbersLeft = false,
      showCandidates = false,
      highlight = {
        enabled = true,
        row = true,
        column = true,
        square = true,
        errors = false,
        sameNumber = true
      },
      difficulty = 1
    }
  };

  settings.readSettings(game);

  core.createNewBoard(game)

  events.setup(game);

  return game

end

return M
