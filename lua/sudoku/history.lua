local fs = require("sudoku.fs");

local M = {};

local function getHistoryFile()
  local historyFile = fs.read("history.json");
  if historyFile == nil then
    historyFile = {};
  end
  return historyFile;
end

---comment
---@param board Board
---@return table
local function encodeBoard(board)
  local cells = {};
  local endCells = {};

  for i = 1, 81 do
    local cell = board.cells[i];
    endCells[i] = cell.set and cell.set or 0;
    cells[i] = cell.number and cell.number or 0;
  end

  return {
    cells = cells,
    endCells = endCells,
    difficulty = board.difficulty,
    startTime = board.startTime;
    endTime = board.endTime;
  }
end

---@param board Board
M.saveBoard = function(board)
  local historyFile = getHistoryFile();
  table.insert(historyFile, encodeBoard(board));
  fs.write("history.json", historyFile);
end

return M
