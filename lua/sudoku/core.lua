local sudoku = require("sudoku.sudoku")

local M = {}

M.getCell = function(board, x, y)
  return board.cells[M.positionToIndex(x, y)]
end

M.positionToIndex = function(x, y)
  return (y - 1) * 9 + x
end

M.indexToPosition = function(index)
  return (index - 1) % 9 + 1, math.floor((index - 1) / 9) + 1
end

M.setCell = function(board, x, y, number)

  local cellIndex = M.positionToIndex(x, y);
  -- local numbers = M.boardToNumbers(board);
  -- local isValid = sudoku.isValidNumber(numbers, cellIndex, number);

  board.cells[cellIndex].set = number

end

M.clearCell = function(board, x, y)
  board.cells[M.positionToIndex(x, y)].set = nil
end

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

M.checkBoardValid = function(board)
  for i = 1, 81 do
    board.cells[i].__invalid = false
    board.cells[i].errors = {}
  end

  local function getCellValue(cell)
    if board.state == "setup" then
      if cell.number == 0 then
        return nil
      end

      return cell.number
    end
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
          valid = false
          rowCell.__invalid = true
          print("row invalid", rowCellValue, i, j);
          table.insert(rowCell.errors, "row")
        end
        rowSet[rowCellValue] = false
      end

      if colCellValue and colCellValue ~= 0 then
        if colSet[colCellValue] == false then
          valid = false
          colCell.__invalid = true
          print("col invalid", colCellValue, i, j);
          table.insert(colCell.errors, "col")
        end
        colSet[colCellValue] = false
      end

      if squareCellValue and squareCellValue ~= 0 then
        if squareSet[squareCellValue] == false then
          valid = false
          squareCell.__invalid = true
          print("square invalid", squareCellValue, i, j);
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

M.setupSquare = function(board, cx, cy)
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

M.resetBoard = function(board)

  board.startTime = os.time()
  for y = 1, 3 do
    for x = 1, 3 do
      M.setupSquare(board, x, y)
    end
  end

  local numbers = sudoku.createBoard()
  local hidden = sudoku.hideBoard(numbers, 45)
  for i = 1, 81 do
    local cell = board.cells[i]
    cell.number = numbers[i]
    cell.show = hidden[i] ~= 0;
  end

  return board
end

M.setupBoard = function(bufnr)
  local board = {
    cells = {},
    squares = {},
    rows = {},
    cols = {},
    startTime = os.time(),
    difficulty = 60,
    state = "normal",
    viewState = "normal",
    bufnr = bufnr,
  }

  return M.resetBoard(board)
end

return M
