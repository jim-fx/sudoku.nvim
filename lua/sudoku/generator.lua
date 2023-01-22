local example = require("sudoku.data");
local M = {}

M.fillBoard = function (board)
  -- TODO: shuffle the example
  for i = 1, 81 do
    local cell=board.cells[i]
    cell.number = example[i]
    -- cell.set = example[i]
  end
end

M.revealBoard = function (board, percentage)
  for i = 1, 81 do
    if math.random(100) > percentage then
      local cell = board.cells[i]
      cell.show = true
    end
  end
end

return M
