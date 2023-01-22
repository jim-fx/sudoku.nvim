local util = require("sudoku.util")

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
  board.cells[M.positionToIndex(x, y)].set = number
end

M.clearCell = function(board, x, y)
  board.cells[M.positionToIndex(x, y)].set = nil
end

local function candidatesToNumbers(candidates)
  local numbers = {}
  for key, value in pairs(candidates) do
    if value == true then
      numbers[key] = key;
    else
      numbers[key] = -1;
    end
  end
  return numbers
end

M.fillBoard = function(board)
  board.state = "setup"

  local errors = 0;

  for num = 1, 9 do
    for squareIndex = 1, 9 do

      local boardIsValid = M.checkBoardValid(board);
      if boardIsValid == false then
        print("Board is invalid " .. squareIndex)
      end

      local shuffledCells = util.shuffle(board.squares[squareIndex])
      table.sort(shuffledCells, function(a, b)
        return a.entropy > b.entropy
      end);

      local found = false;
      for _, cell in pairs(shuffledCells) do
        if cell.candidates[num] == true and cell.number == 0 then
          cell.number = num;
          cell.setup = true;
          found = true;
          break
        end
      end

      if found == false then
        errors = errors + 1;
      end

    end
  end

  print("Errors: " .. errors)

  board.state = "normal"

  return true;
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
      show = false,
      candidates = {},
      entropy = 9,
      __invalid = false,
      __rowSet = {},
      __colSet = {},
      __squareSet = {},
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

M.revealBoard = function(board, percentage)
  for i = 1, 81 do
    if math.random(100) > percentage then
      local cell = board.cells[i]
      cell.show = true
    end
  end
end

M.resetBoard = function(board)
  for y = 1, 3 do
    for x = 1, 3 do
      M.setupSquare(board, x, y)
    end
  end

  board.shuffledCells = util.shuffle(board.cells);

  M.fillBoard(board)
  M.revealBoard(board, board.difficulty)

  return board
end

M.sortCellsByEntropy = function(board)
  return table.sort(board.cells, function(a, b)
    return util.tableLength(a.candidates) < util.tableLength(b.candidates)
  end)
end

M.calculateBoardEntropy = function(board)

  local totalEntropy = 0;

  for i = 1, 81 do
    local cell = board.cells[i]
    local entropy = 0;
    for _, candidate in pairs(cell) do
      if candidate == true then
        entropy = entropy + 1
      end
    end
    totalEntropy = totalEntropy + entropy
  end

  board.state = "normal"

  return totalEntropy

end

M.setupBoard = function(bufnr)
  local board = {
    cells = {},
    squares = {},
    rows = {},
    cols = {},
    difficulty = 60,
    state = "normal",
    viewState = "normal",
    bufnr = bufnr,
  }

  return M.resetBoard(board)
end


M.checkBoardValid = function(board)
  for i = 1, 81 do
    board.cells[i].__invalid = false
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

      if rowCellValue then
        if rowSet[rowCellValue] == false then
          valid = false
          rowCell.__invalid = true
        end
        rowSet[rowCellValue] = false
      end

      if colCellValue then
        if colSet[colCellValue] == false then
          valid = false
          colCell.__invalid = true
        end
        colSet[colCellValue] = false
      end

      if squareCellValue then
        if squareSet[squareCellValue] == false then
          valid = false
          squareCell.__invalid = true
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

return M
