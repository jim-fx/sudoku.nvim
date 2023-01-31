local core = require("sudoku.core")
local M = {}

M.renderBoard = function(board)
  local lines = {}

  local i = 0

  for y = 1, 9 do
    local line = ""

    for x = 1, 9 do
      local index = core.positionToIndex(x, y)
      local cell = board.cells[index]

      if board.viewState == "result" then
        if cell.number ~= 0 then
          line = line .. cell.number .. " "
        else
          line = line .. "∙" .. " "
        end
      elseif board.viewState == "entropy" then
        line = line .. cell.entropy .. " "
      else
        if cell.show then
          line = line .. cell.number .. " "
        elseif cell.set ~= 0 and cell.set ~= nil then
          line = line .. (cell.set and cell.set or "∙") .. " "
        else
          line = line .. "∙ "
        end
      end

      if x % 3 == 0 then
        line = line .. "│ "
      end
      if x == 1 then
        line = "│ " .. line
      end
    end

    if (y - 1) % 3 == 0 then
      i = i + 1
      if y == 1 then
        lines[i] = "╭───────┬───────┬───────╮ "
      else
        lines[i] = "├───────┼───────┼───────┤"
      end
    end

    i = i + 1
    lines[i] = line
  end
  lines[i + 1] = "╰───────┴───────┴───────╯ "

  return lines
end

return M
