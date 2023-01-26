local game = require("sudoku.game")

local M = {}

local function createNewSudoku()
  game.init();
end

M.setup = function()
  vim.api.nvim_create_user_command("Sudoku", createNewSudoku, {})
end

return M
