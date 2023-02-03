local sudoku = require("sudoku.sudoku")
local util = require("sudoku.util")
local history = require("sudoku.history")

local M = {}

---@class Cell
---@field number number
---@field errors string[]
---@field set number
---@field show boolean
---@field candidates number[]
---@field entropy number
---@field tip boolean
---@field __colSet number[]
---@field __rowSet number[]
---@field __squareSet number[]

---@class Board
---@field finished boolean
---@field cells Cell[]
---@field history BoardHistory
---@field squares Cell[][]
---@field rows Cell[][]
---@field cols Cell[][]
---@field tips number
---@field startTime number
---@field endTime number?
---@field difficulty number

---@class BoardHistory
---@field steps number[][]
---@field index number

---@param board Board
M.getCell = function(board, x, y)
  return board.cells[M.positionToIndex(x, y)]
end

local function getCursorIndex()
  local x, y = util.getPos()
  return M.positionToIndex(x + 1, y + 1)
end

M.setCursorCellValue = function(board, value)
  return M.setCellValue(board, getCursorIndex(), value)
end

---@param board Board
---@param cell Cell
---@return number | nil
M.getCellIndex = function(board, cell)

  local index = nil;

  for i = 1, 81 do
    if board.cells[i] == cell then
      index = i;
      break;
    end
  end

  return index;
end

---comment
---@param board Board
---@param index  integer
---@param value number
---@return Cell | nil
M.setCellValue = function(board, index, value)
  local cell = board.cells[index];
  if cell == nil then
    return
  end
  local currentValue = cell.set
  cell.set = value
  history.addBoardStep(board, index, currentValue, value)
  return cell;
end

M.positionToIndex = function(x, y)
  return (y - 1) * 9 + x
end

M.indexToPosition = function(index)
  return (index - 1) % 9 + 1, math.floor((index - 1) / 9) + 1
end

M.indexToScreenPosition = function(index)
  local _cx, _cy = M.indexToPosition(index);
  local sx = _cx * 2 + math.floor((_cx - 1) / 3) * 2;
  local sy = _cy + math.floor((_cy / 4));
  if sy == 8 then
    -- no idea why this is needed
    sy = 9
  end
  return sx, sy
end

---Clears the cell at the given position
---@param board Board
---@param x number
---@param y number
M.clearCell = function(board, x, y)
  return M.setCellValue(board, M.positionToIndex(x, y), 0)
end

---@param board Board
M.boardToNumbers = function(board)
  local numbers = {};

  for i = 1, 81 do

    local cell = board.cells[i]
    if cell.set ~= 0 then
      numbers[i] = cell.set
    elseif cell.show then
      numbers[i] = cell.number
    else
      numbers[i] = 0
    end

  end

  return numbers
end

---@param board Board
M.totalMissingCells = function(board)
  local count = 0

  for i = 1, 81 do
    local cell = board.cells[i]
    if cell.show == false and cell.set == 0 then
      count = count + 1
    end
  end

  return count;
end

---@param board Board
---@return Cell
M.getCursorCell = function(board)
  local x, y = util.getPos();
  return M.getCell(board, x + 1, y + 1);
end


---@param board Board
M.checkBoardValid = function(board)

  local missingCells = M.totalMissingCells(board);
  local isWon = missingCells == 0;
  if isWon then
    board.finished = true
  end

  for i = 1, 81 do
    board.cells[i].__invalid = false
    board.cells[i].errors = {}
  end

  local function getCellValue(cell)
    return cell.show and cell.number or cell.set
  end

  local valid = true

  for i = 1, 9 do
    local row = board.rows[i]
    local col = board.cols[i]
    local square = board.squares[i]

    -- we start with all numbers, deleting every one we find
    -- so that we can use the ones left as candidates for the cells
    local rowSet = { true, true, true, true, true, true, true, true, true }
    local colSet = { true, true, true, true, true, true, true, true, true }
    local squareSet = { true, true, true, true, true, true, true, true, true }

    for j = 1, 9 do
      local rowCell = row[j]
      rowCell.__rowSet = rowSet
      local colCell = col[j]
      colCell.__colSet = colSet
      local squareCell = square[j]
      squareCell.__squareSet = squareSet

      local rowCellValue = getCellValue(rowCell)
      local colCellValue = getCellValue(colCell)
      local squareCellValue = getCellValue(squareCell)

      if rowCellValue and rowCellValue ~= 0 then
        if rowSet[rowCellValue] == false then

          for k = 1, 9 do
            local cell = board.rows[i][k];
            local cValue = getCellValue(cell);
            if cValue == colCellValue and cValue ~= 0 then
              cell.__invalid = true
              table.insert(cell.errors, "row")
            end
          end

          valid = false
          rowCell.__invalid = true
          table.insert(rowCell.errors, "row")
        end
        rowSet[rowCellValue] = false
      end

      if colCellValue and colCellValue ~= 0 then
        if colSet[colCellValue] == false then
          for k = 1, 9 do
            local cell = board.cols[i][k];
            local cValue = getCellValue(cell);
            if cValue == colCellValue and cValue ~= 0 then
              cell.__invalid = true
              table.insert(cell.errors, "col")
            end
          end

          valid = false
          colCell.__invalid = true
          table.insert(colCell.errors, "col")
        end
        colSet[colCellValue] = false
      end

      if squareCellValue and squareCellValue ~= 0 then
        if squareSet[squareCellValue] == false then

          for k = 1, 9 do
            local cell = board.squares[i][k];
            local cValue = getCellValue(cell);
            if cValue == colCellValue and cValue ~= 0 then
              cell.__invalid = true
              table.insert(cell.errors, "square")
            end
          end

          valid = false
          squareCell.__invalid = true
          table.insert(squareCell.errors, "square")
        end
        squareSet[squareCellValue] = false
      end

    end

  end

  for cellIndex = 1, 81 do
    local cell = board.cells[cellIndex]
    local candidates = { true, true, true, true, true, true, true, true, true }
    local entropy = 9;
    for n = 1, 9 do
      if cell.__rowSet[n] == false or cell.__colSet[n] == false or cell.__squareSet[n] == false then
        candidates[n] = false
        entropy = entropy - 1
      end
    end
    cell.entropy = entropy
    cell.candidates = candidates
  end

  return valid
end



local function setupSquare(board, cx, cy)
  local cells = {}

  for i = 1, 9 do
    -- coordinates relative to square
    local x = (i - 1) % 3
    local y = math.floor((i - 1) / 3)

    -- coordinates relative to grid
    local gx = (cx - 1) * 3 + x + 1
    local gy = (cy - 1) * 3 + y + 1

    -- global index
    local index = M.positionToIndex(gx, gy)

    local cell = {
      number = 0,
      set = 0,
      show = false,
      candidates = {},
      entropy = 9,
    }

    if board.rows[gy] == nil then
      board.rows[gy] = {}
    end
    board.rows[gy][gx] = cell

    if board.cols[gx] == nil then
      board.cols[gx] = {}
    end
    board.cols[gx][gy] = cell

    board.cells[index] = cell
    cells[i] = cell
  end

  board.squares[(cy - 1) * 3 + cx] = cells
end

M.createNewBoard = function(game)

  ---@type Board
  local board = {
    finished = false,
    cells = {},
    squares = {},
    history = {
      index = 0,
      steps = {},
    },
    rows = {},
    cols = {},
    tips = 0,
    startTime = os.time(),
    difficulty = game.settings.difficulty,
  }

  for y = 1, 3 do
    for x = 1, 3 do
      setupSquare(board, x, y)
    end
  end

  local numbers = sudoku.createBoard()

  local hidden = {}
  if board.difficulty == 1 then
    hidden = sudoku.hideBoard(numbers, 35)
  elseif board.difficulty == 2 then
    hidden = sudoku.hideBoard(numbers, 45)
  elseif board.difficulty == 3 then
    hidden = sudoku.hideBoard(numbers, 50)
  elseif board.difficulty == 4 then
    hidden = sudoku.hideBoard(numbers, 55)
  end

  for i = 1, 81 do
    local cell = board.cells[i]
    cell.number = numbers[i]
    cell.show = hidden[i] ~= 0;
  end
  game.board = board
  table.insert(game.boards, board)

  return board;
end

return M
