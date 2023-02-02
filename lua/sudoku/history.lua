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
  local history = {};

  for i = 1, 81 do
    local cell = board.cells[i];
    endCells[i] = cell.set and cell.set or 0;
    cells[i] = cell.number and cell.number or 0;
  end

  for i = 1, #board.history.steps do
    local step = board.history.steps[i];
    history[i * 3 + 0] = step[1];
    history[i * 3 + 1] = step[1];
    history[i * 3 + 2] = step[1];
  end

  return {
    cells = cells,
    history = history,
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

---@param board Board
---@param cellIndex number
---@param oldValue number
---@param newValue number
M.addBoardStep = function(board, cellIndex, oldValue, newValue)

  if board.history == nil then
    board.history = {
      steps = {},
      index = 0,
    }
  end

  if board.history.index ~= #board.history.steps then
    -- remove all steps after the current one
    for i = #board.history.steps, board.history.index + 1, -1 do
      table.remove(board.history.steps, i);
    end
  end

  table.insert(board.history.steps, {
    cellIndex,
    oldValue,
    newValue,
  });
  board.history.index = #board.history.steps;
end

---@param board Board
M.undoBoardStep = function(board)
  local currentStep = board.history.steps[board.history.index];
  if currentStep == nil then
    return;
  end

  local cell = board.cells[currentStep[1]];
  if cell == nil then
    return;
  end

  cell.set = currentStep[2];
  board.history.index = board.history.index - 1;
end

---@param board Board
M.redoBoardStep = function(board)
  -- we are already a the last step
  if board.history.index == #board.history.steps then
    return;
  end

  board.history.index = board.history.index + 1;
  local currentStep = board.history.steps[board.history.index];
  local cell = board.cells[currentStep[1]];
  if cell ~= nil then
    cell.set = currentStep[3];
  end

end


return M
