local renderer = require("sudoku.renderer")
local util = require("sudoku.util")
local core = require("sudoku.core")
local nvim = vim.api

local M = {}

M.drawUI = function(board)
  local lines = {
    "╭───────────┬─────────┬───────╮",
    "│ [R]estart │ [C]lose │ [T]ip │",
    "╰───────────┴─────────┴───────╯",
  }

  return lines
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

  return fx, fy
end

M.render = function(board)
  local lines = util.tableConcat(renderer.renderBoard(board), M.drawUI(board))

  local isValid = core.checkBoardValid(board) and "valid" or "invalid"

  lines = util.tableConcat(lines, { "Board is " .. isValid })
  util.tableConcat(lines, { "TotalEntropy: " .. core.calculateBoardEntropy(board) })

  local x, y = M.getPos();
  lines = util.tableConcat(lines, { "x: " .. x .. " y: " .. y });

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


  nvim.nvim_buf_set_option(board.bufnr, "modifiable", true)
  nvim.nvim_buf_set_lines(board.bufnr, 0, -1, false, lines)
  nvim.nvim_buf_set_option(board.bufnr, "modifiable", false)

  -- M.highlight(board)
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
    board.cells[i].set = nil
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

local function handleToggleResult(board)
  if board.viewState == "normal" then
    board.viewState = "result"
  elseif board.viewState == "result" then
    board.viewState = "entropy"
  elseif board.viewState == "entropy" then
    board.viewState = "normal"
  end

  M.render(board)
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

vim.cmd("hi SameNumber gui=italic guibg=#440000")
M.highlight = function(board)
  -- vim.cmd("hi SameNumber gui=bold")

  local x, y = M.getPos();

  local cy = vim.fn.line(".")
  local cx = vim.fn.col(".")

  if y ~= -1 then
    -- highlight row
    -- nvim.nvim_buf_add_highlight(board.bufnr, ns, "Visual", cy - 1, 2, 48)
    vim.highlight.range(board.bufnr, ns, "Visual", { cy - 1, 2 }, { cy - 1, 48 }, { inclusive = true, regtype = "b" })
  end

  if y ~= -1 then
    -- highlight square
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
    if cell.set ~= nil then
    end

  end

  for i = 1, 81 do
    local _cx, _cy = core.indexToPosition(i);
    local c = core.getCell(board, _cx, _cy)
    if c.set == 8 then
      -- print(i .. " " .. _cx .. " " .. _cy)
      local sx = (_cx - 1) * 3 + 2 - math.floor(x / 3);
      local sy = (_cy + 1) + math.floor((_cy) / 4) - 1;
      vim.highlight.range(board.bufnr, ns, "SameNumber", { sy, sx }, { sy, sx + 1 },
        { reqtype = "", priority = 60000 })
    end
  end


end

M.setupEvents = function(board)
  vim.keymap.set({ "n" }, "x", function()
    handleDelete(board)
  end, { buffer = board.bufnr })

  vim.keymap.set({ "n" }, "t", function()
    handleToggleResult(board)
  end, { buffer = board.bufnr })

  vim.keymap.set({ "n" }, "+", function()
    handleIncrement(board, 1)
  end, { buffer = board.bufnr })

  vim.keymap.set({ "n" }, "-", function()
    handleIncrement(board, -1)
  end, { buffer = board.bufnr })

  vim.keymap.set({ "n" }, "r", function()
    core.resetBoard(board)
    M.render(board)
  end, { buffer = board.bufnr })

  vim.keymap.set({ "n" }, "c", function()
    handleClear(board)
    M.render(board)
  end, { buffer = board.bufnr })

  for i = 1, 9 do
    vim.keymap.set({ "n" }, "r" .. tostring(i), function()
      handleInsert(board, i)
    end, { buffer = board.bufnr })
  end

  for i = 1, 9 do
    vim.keymap.set({ "n" }, "f" .. tostring(i), function()
      handleFill(board, i)
    end, { buffer = board.bufnr })
  end

  nvim.nvim_create_autocmd("CursorMoved", {
    group = vim.api.nvim_create_augroup("render-asd", { clear = true }),
    callback = function()
      M.render(board)
    end,
  })

end

return M
