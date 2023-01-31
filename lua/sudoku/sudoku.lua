local function isNumberPossible(numbers, cellIndex, num)

  local x = (cellIndex - 1) % 9
  local y = math.floor((cellIndex - 1) / 9)
  local squareX = math.floor(x / 3)
  local squareY = math.floor(y / 3)
  local squareRootIndex = squareX * 3 + squareY * 27 + 1;

  for i = 1, 9 do
    local columnIndex = x + 9 * (i - 1) + 1;
    local rowIndex = math.floor((cellIndex - 1) / 9) * 9 + i;
    local squareIndex = squareRootIndex + (i - 1) % 3 + math.floor((i - 1) / 3) * 9;

    if numbers[columnIndex] == num then
      return false;
    end

    if numbers[rowIndex] == num then
      return false;
    end

    if numbers[squareIndex] == num then
      return false;
    end

  end

  return true;
end

local function isSolved(numbers)
  for i = 1, 81 do
    if numbers[i] == 0 then
      return false, i;
    end
  end
  return true, 0
end

local function shuffle(x)
  local shuffled = {}
  for _, v in ipairs(x) do
    local pos = math.random(1, #shuffled + 1)
    table.insert(shuffled, pos, v)
  end
  return shuffled
end

local function genRandomIndeces(num)
  local indeces = {}
  for i = 1, num do
    indeces[i] = i
  end
  return shuffle(indeces)
end

local function solve(sudoku)

  local solved, cellIndex = isSolved(sudoku)
  if solved then return true, sudoku end

  local numbers = genRandomIndeces(9)

  for i = 1, 9 do
    local num = numbers[i]
    if isNumberPossible(sudoku, cellIndex, num) then
      sudoku[cellIndex] = num;
      solved = solve(sudoku)
      if solved then return true, sudoku end
      sudoku[cellIndex] = 0;
    end
  end

  return false, sudoku;

end

local function hide(numbers, hideCount)

  local hidden = {}

  local indeces = genRandomIndeces(81)

  for i = 1, 81 do
    if i < hideCount then
      hidden[indeces[i]] = 0;
    else
      hidden[indeces[i]] = numbers[indeces[i]];
    end
  end

  return hidden
end

-- fills a random cell in all squares with the provided number
local function fillNumberInSquares(numbers, num)

  -- loop through all squares
  for squareIndex = 1, 9 do

    local indeces = genRandomIndeces(9);

    for j = 1, 9 do
      local i = indeces[j];

      local squareRootIndex = (squareIndex - 1) % 3 * 3 + math.floor((squareIndex - 2) / 3) * 27 + 1;
      local cellIndexOffset = (i - 1) % 3 + math.floor((i - 1) / 3) * 9;
      local cellIndex = squareRootIndex + cellIndexOffset

      if isNumberPossible(numbers, cellIndex, num) then
        numbers[cellIndex] = num;
        break;
      end

    end
  end

end

local function createEmptyBoard()
  local board = {}
  for i = 1, 81 do
    board[i] = 0
  end
  return board;
end

local function createSudokuBoard()
  local board = createEmptyBoard()
  fillNumberInSquares(board, 1)
  solve(board);
  return board;
end

return {
  solveBoard = solve,
  createBoard = createSudokuBoard,
  isValidNumber = isNumberPossible,
  hideBoard = hide
};
