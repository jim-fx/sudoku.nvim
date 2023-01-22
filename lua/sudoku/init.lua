local core = require("sudoku.core")
local ui = require("sudoku.ui")
local M = {}

local function createNewSudoku()

  local buf = ui.setupBuffer();

  local board = core.setupBoard(buf)
  ui.render(board)
  ui.setupEvents(board);

end

M.setup = function()
  vim.api.nvim_create_user_command("Sudoku", createNewSudoku, {})
end

return M
