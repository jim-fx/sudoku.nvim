local core = require("sudoku.core");
local ui = require("sudoku.ui");
local events = require("sudoku.events");
local settings = require("sudoku.settings");
local M = {}

local namespace = vim.api.nvim_create_namespace("jim-fx/sudoku.nvim");

M.init = function()

  local buf = ui.setupBuffer();

  local game = {
    bufnr = buf,
    ns = namespace,
    board = nil,
    boards = {},
    viewState = "normal",
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
