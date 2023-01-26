local renderer = require("sudoku.renderer")
local util = require("sudoku.util")
local core = require("sudoku.core")
local nvim = vim.api

local M = {}

local function drawWin(board)

  local endTime = os.time()
  local diff = os.difftime(endTime, board.startTime);

  return {
    "You have solved the Sudoku!",
    "Time: " .. string.format("%.2d:%.2d:%.2d", diff / (60 * 60), diff / 60 % 60, diff % 60),
  }
end

local function drawUI(board)

  local viewState = board.viewState;
  local lines = {
    "",
    " Sudoku",
    "╭───────────────╮",
    "│ [gr] restart " .. (viewState == "restart" and "-" or " ") .. "│",
    " ├───────────────┤",
    "│ [gh] help    " .. (viewState == "help" and "-" or " ") .. "│",
    "├───────────────┤",
    "│ [gt] tip      │",
    " ├───────────────┤",
    "│ [gs] settings" .. (viewState == "settings" and "-" or " ") .. "│",
    "╰───────────────╯"
  }
  -- ╭───────┬───────┬───────╮
  -- ├───────┼───────┼───────┤

  return lines
end

local function drawSettings()
  return {
    "-- Settings --",
  }
end

local function drawHelp()
  return {
    "Sudoku Rules: ",
    "1. Each row must contain the numbers 1-9",
    "2. Each column must contain the numbers 1-9",
    "3. Each 3x3 box must contain the numbers 1-9",
    "",
    "Keymappings:",
    "[1..9] -> Insert a number",
    "[x]    -> Clear a cell",
    "[gr]   -> Restart the game",
    "[gh]   -> Show help",
    "[gt]   -> Show a tip",
  }
end

local function drawRestart(board)

  local changedCells = 0;
  for i = 1, 81 do
    local cell = board.cells[i]
    if cell.set ~= 0 then
      changedCells = changedCells + 1
    end
  end

  return {
    "You have changed " .. changedCells .. " cells, are you sure you want to reset?",
    "[y]es [n]o"
  }
end

M.getPos = function()
  local y = vim.fn.line(".")
  local x = vim.fn.virtcol(".")

  local fx = math.floor((x - 3) / 2)
  if (fx + 1) % 4 == 0 or x % 2 == 0 then
    fx = -1
  else
    fx = fx - math.floor((fx + 1) / 4)
  end

  local fy = y - 2
  if (fy + 1) % 4 == 0 then
    fy = -1
  else
    fy = fy - math.floor(fy / 4)
  end

  if fx > 8 then
    fx = -1
  end

  if fy > 8 then
    fy = -1
  end

  return fx, fy
end

M.render = function(board)
  local lines = renderer.renderBoard(board)

  local ui = drawUI(board)
  for i = 1, #ui do
    lines[i] = lines[i] .. "" .. ui[i]
  end

  local isValid = core.checkBoardValid(board) and "valid" or "invalid";
  local missingCells = core.totalMissingCells(board);

  if missingCells == 0 then
    lines = util.tableConcat(lines, drawWin(board));
  end

  if false then
    lines = util.tableConcat(lines, { "Board is " .. isValid });
    lines = util.tableConcat(lines, { "Missing cells: " .. missingCells });

    local x, y = M.getPos();
    lines = util.tableConcat(lines, { "Cursor x: " .. x + 1 .. " y: " .. y + 1 });

    local cell = core.getCell(board, x + 1, y + 1);
    if cell ~= nil then

      local cellLine = "cell: " .. cell.number or cell.set;


      if cell.errors ~= nil then
        for key, value in pairs(cell.errors) do
          cellLine = cellLine .. " " .. value
        end
      end

      lines = util.tableConcat(lines, { cellLine });

    end

    lines = util.tableConcat(lines, { "viewState: " .. board.viewState .. " state: " .. board.state });

    if x ~= -1 and y ~= -1 then
      local cell = core.getCell(board, x + 1, y + 1);
      if cell ~= nil then

        local candidates = cell.candidates;
        local candidateLine = "";
        for i = 1, 9 do
          candidateLine = candidateLine .. (candidates[i] == true and i or "x") .. " "
        end
        candidateLine = "Candidates: " .. candidateLine .. " #" .. util.tableLength(candidates)
        lines = util.tableConcat(lines, { candidateLine });
      end
    end

  end

  if board.viewState == "restart" then
    lines = util.tableConcat(lines, drawRestart(board));
  end


  if board.viewState == "help" then
    lines = util.tableConcat(lines, drawHelp(board));
  end

  if board.viewState == "settings" then
    lines = util.tableConcat(lines, drawSettings(board));
  end

  nvim.nvim_buf_set_option(board.bufnr, "modifiable", true)
  nvim.nvim_buf_set_lines(board.bufnr, 0, -1, false, lines)
  nvim.nvim_buf_set_option(board.bufnr, "modifiable", false)

  -- M.highlight(board)
  -- M.highlightLine(board)
end

M.setupBuffer = function()
  -- Create new empty buffer
  local buf = nvim.nvim_call_function("bufnr", { "Sudoku" })
  if buf == -1 then
    buf = nvim.nvim_create_buf(false, true)
  end
  nvim.nvim_buf_set_name(buf, "Sudoku")
  nvim.nvim_set_current_buf(buf)
  return buf
end

local function handleDelete(board)
  local x, y = M.getPos()
  if x ~= -1 and y ~= -1 then
    core.clearCell(board, x + 1, y + 1)
    M.render(board)
  end
end

local function handleClear(board)
  for i = 1, 81 do
    board.cells[i].set = 0
    board.cells[i].show = false
    board.cells[i].candidates = {}
    board.cells[i].number = 0
  end
end

local function handleInsert(board, number)
  local x, y = M.getPos()
  if x ~= -1 and y ~= -1 then
    core.setCell(board, x + 1, y + 1, number)
    M.render(board)
  else
    print("Invalid position " .. x .. "," .. y)
  end
end

local function handleFill(board, num)
  for i = 1, 81 do
    board.cells[i].set = num
  end
  M.render(board)
end

local function handleIncrement(board, number)
  local x, y = M.getPos()

  local cell = core.getCell(board, x + 1, y + 1)

  if cell.set == nil then
    if number == -1 then
      cell.set = 9
    else
      cell.set = 1
    end
  elseif cell.set == 9 and number == 1 then
    cell.set = 1
  elseif cell.set == 1 and number == -1 then
    cell.set = 9
  else
    cell.set = cell.set + number
  end

  M.render(board)
end

local ns = vim.api.nvim_create_namespace("my_namespace")
-- vim.cmd("hi SameNumber gui=italic guibg=#440000")

M.highlightLine = function(board)

  vim.api.nvim_buf_clear_namespace(board.bufnr, ns, 0, -1)

  local x, y = M.getPos();

  local cy = vim.fn.line(".")
  local cx = vim.fn.virtcol(".")

  for iy = 1, 11 do
    nvim.nvim_buf_set_extmark(board.bufnr, ns, iy, cx, { end_col = cx + 5, hl_group = "Visual" })
  end

  -- print("x: " .. x .. " y: " .. y)
end

M.highlight = function(board)

  local x, y = M.getPos();

  local cy = vim.fn.line(".")
  local cx = vim.fn.col(".")

  -- highlight current row
  if y ~= -1 then
    vim.highlight.range(board.bufnr, ns, "Visual", { cy - 1, 3 }, { cy - 1, 48 }, { inclusive = true, regtype = "b" })
  end

  -- highlight square
  if y ~= -1 then
    local fx = math.floor((vim.fn.virtcol(".") - 3) / 2)
    fx = fx - math.floor((fx + 1) / 4)
    local sx = math.floor(fx / 3) * 16 + 3;
    local sy = math.floor(y / 3) * 4;
    for i = 1, 3 do
      vim.highlight.range(board.bufnr, ns, "Visual", { sy + i, sx }, { sy + i, sx + 12 },
        { inclusive = true, regtype = "b" })
    end
  end

  if x ~= -1 and y ~= -1 then
    -- highlight current column
    for i = 1, 11 do
      if i % 4 == 0 then
        vim.highlight.range(board.bufnr, ns, "Visual", { i, math.floor(cx * 1.5) + 1 }, { i, math.floor(cx * 1.5) + 2 },
          { reqtype = "" })
      else
        vim.highlight.range(board.bufnr, ns, "Visual", { i, cx - 1 }, { i, cx + 1 }, { inclusive = true })
      end
    end

    -- highlight same numbers
    local cell = core.getCell(board, x + 1, y + 1)
    local cellValue = cell.set or cell.number;
    if cellValue ~= nil and cellValue ~= 0 then
      print("Highlight: " .. cellValue)
      for i = 1, 81 do
        local _cx, _cy = core.indexToPosition(i);
        local c = core.getCell(board, _cx, _cy)
        local cellValueMatches = cellValue == (c.set or c.number);
        if cellValueMatches then
          -- print(i .. " " .. _cx .. " " .. _cy)
          local sx = (_cx - 1) * 3 + 2 - math.floor(x / 3);
          local sy = (_cy + 1) + math.floor((_cy) / 4) - 1;
          vim.highlight.range(board.bufnr, ns, "Visual", { sy, sx }, { sy, sx + 1 },
            { reqtype = "", priority = 60000 })
        end
      end
    end

  end

end

local function handleRestart(board)

  local changedCells = 0;
  for i = 1, 81 do
    local cell = board.cells[i]
    if cell.set ~= 0 then
      changedCells = changedCells + 1
    end
  end

  if board.viewState == "restart" or changedCells == 0 then
    core.resetBoard(board)
    board.viewState = "normal"
  else
    board.viewState = "restart"
  end

  M.render(board)
end

M.setupEvents = function(board)
  vim.keymap.set({ "n" }, "x", function()
    handleDelete(board)
  end, { buffer = board.bufnr, desc = "Clear single sudoku cell" })

  vim.keymap.set({ "n" }, "+", function()
    handleIncrement(board, 1)
  end, { buffer = board.bufnr })

  vim.keymap.set({ "n" }, "-", function()
    handleIncrement(board, -1)
  end, { buffer = board.bufnr })

  vim.keymap.set({ "n" }, "gh", function()
    board.viewState = (board.viewState == "help") and "normal" or "help"
    M.render(board)
  end, { buffer = board.bufnr, desc = "Show sudoku help" })

  vim.keymap.set({ "n" }, "gr", function()
    handleRestart(board)
  end, { buffer = board.bufnr, desc = "Start a new sudoku board" })

  vim.keymap.set({ "n" }, "n", function()
    if board.viewState == "restart" then
      board.viewState = "normal"
      M.render(board)
    end
  end, { buffer = board.bufnr, desc = "Start a new sudoku board" })

  vim.keymap.set({ "n" }, "y", function()
    if board.viewState == "restart" then
      handleRestart(board)
    end
  end, { buffer = board.bufnr, desc = "Start a new sudoku board" })

  vim.keymap.set({ "n" }, "gc", function()
    handleClear(board)
    M.render(board)
  end, { buffer = board.bufnr, desc = "Clear Sudoku board" })

  vim.keymap.set({ "n" }, "gs", function()
    board.viewState = (board.viewState == "settings") and "normal" or "settings"
    M.render(board)
  end, { buffer = board.bufnr, desc = "Clear Sudoku board" })

  for i = 1, 9 do
    vim.keymap.set({ "n" }, tostring(i), function()
      handleInsert(board, i)
    end, { buffer = board.bufnr, desc = "Insert " .. i .. " into sudoku" })
  end

  nvim.nvim_create_autocmd("CursorMoved", {
    group = vim.api.nvim_create_augroup("render-asd", { clear = true }),
    callback = function()
      M.render(board)
    end,
  })

end

return M
