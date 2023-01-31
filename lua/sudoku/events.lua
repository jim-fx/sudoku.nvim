local core = require("sudoku.core")
local ui = require("sudoku.ui");
local util = require("sudoku.util");
local settings = require("sudoku.settings");

local M = {}
local nvim = vim.api;

---@enum actions
M.actions = {
  "insert_1",
  "insert_2",
  "insert_3",
  "insert_4",
  "insert_5",
  "insert_6",
  "insert_7",
  "insert_8",
  "insert_9",
  "game_new",
  "game_restart",
  "game_exit",
  "view_settings",
  "view_tip",
  "view_help",
}

---@param game Game
local function handleDelete(game)
  local x, y = util.getPos()
  if x ~= -1 and y ~= -1 and x ~= nil and y ~= nil then
    core.clearCell(game.board, x + 1, y + 1)
    ui.render(game)
  end
end

---Clear all cells in the current board
---@param game Game
local function handleClear(game)
  local board = game.board;
  for i = 1, 81 do
    board.cells[i].set = 0
    board.cells[i].show = false
    board.cells[i].candidates = {}
    board.cells[i].number = 0
  end
end

---Insert a number into the specified position
---@param game Game
---@param number number
local function handleInsert(game, number)
  local x, y = util.getPos()
  if x ~= -1 and y ~= -1 then

    local cell = core.getCell(game.board, x + 1, y + 1)
    if cell.tip == true then
      cell.tip = false
      game.viewState = "normal"
    end
    cell.set = number

    ui.render(game)
  else
    print("Invalid position " .. x .. "," .. y)
  end
end

---@param game Game
---@param state ViewState
local function setViewState(game, state)
  game.viewState = (game.viewState == state) and "normal" or state;
  ui.render(game)
  settings.writeSettings(game);
end

---@param game Game
---@param number number
local function handleIncrement(game, number)

  local cell = core.getCursorCell(game)

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

  ui.render(game)
end

---@param game Game
local function handleShowTip(game)

  if game.viewState == "tip" then
    for i = 1, 81 do
      local cell = game.board.cells[i]
      cell.tip = false;
    end
    game.viewState = "normal"
  else
    game.viewState = "tip";

    local cell = nil;
    local shuffledCells = util.shuffle(game.board.cells)
    for i = 1, 81 do
      local c = shuffledCells[i]
      if c.entropy == 1 and c.show == false then
        cell = c
        break
      end
    end

    if cell ~= nil then
      game.board.tips = game.board.tips + 1
      cell.tip = true;
    end

  end

end

---@param game Game
local function handleNewGame(game)

  local changedCells = 0;
  for i = 1, 81 do
    local cell = game.board.cells[i]
    if cell.set ~= 0 then
      changedCells = changedCells + 1
    end
  end

  if game.viewState == "new" or changedCells == 0 or game.board.finished then
    core.createNewBoard(game)
    game.viewState = "normal"
  else
    game.viewState = "new"
  end

  ui.render(game)
end

local function handleMouseClick(game)
  local mousePos = vim.fn.getmousepos();
  local winId = mousePos.winid
  local col = mousePos.column
  local row = mousePos.line



  if game.viewState == "normal" then
    if mousePos.line == 14 then
      handleInsert(game, math.floor(col / 2) + 1);
      -- vim.notify("Num: " .. math.floor(mousePos.column / 2) + 1);
      return;
    end
  end

  nvim.nvim_win_set_cursor(winId, { row, col })

  if mousePos.column > 42 then
    if mousePos.screenrow == 4 then
      handleNewGame(game)
    elseif mousePos.screenrow == 6 then
      setViewState(game, "help")
    elseif mousePos.screenrow == 8 then
      setViewState(game, "tip")
    elseif mousePos.screenrow == 10 then
      setViewState(game, "settings")
    end
  end

  if game.viewState == "settings" then
    settings.handleToggleSetting(game)
  end

end

M.setup = function(game)

  nvim.nvim_buf_create_user_command(game.bufnr, "Sudoku", function()
    print("Sudoku command")
  end, {});

  vim.keymap.set({ "n" }, "+", function()
    handleIncrement(game, 1)
  end, { buffer = game.bufnr })

  vim.keymap.set({ "n" }, "-", function()
    handleIncrement(game, -1)
  end, { buffer = game.bufnr })

  vim.keymap.set({ "n" }, "gh", function()
    setViewState(game, "help")
  end, { buffer = game.bufnr, desc = "Show sudoku help" })

  vim.keymap.set({ "n" }, "gn", function()
    handleNewGame(game)
  end, { buffer = game.bufnr, desc = "Start a new sudoku board" })

  vim.keymap.set({ "n" }, "<LeftMouse>", function()
    handleMouseClick(game)
  end, { buffer = game.bufnr, desc = "Insert 1" })

  -- vim.keymap.set({ "n" }, "<LeftRelease>", function()
  --   handleMouseClick(game)
  -- end, { buffer = game.bufnr, desc = "Insert 1" })

  vim.keymap.set({ "n" }, "gd3b", function()
    game.__debug = not game.__debug
    ui.render(game)
  end, { buffer = game.bufnr, desc = "Start a new sudoku board" })

  vim.keymap.set({ "n" }, "n", function()
    if game.viewState == "restart" then
      game.viewState = "normal"
      ui.render(game)
    end
  end, { buffer = game.bufnr, desc = "Start a new sudoku board" })

  vim.keymap.set({ "n" }, "r", function()
    if game.viewState == "restart" then
      handleNewGame(game)
    end
  end, { buffer = game.bufnr, desc = "Start a new sudoku board" })

  vim.keymap.set({ "n" }, "gt", function()
    handleShowTip(game)
    ui.render(game)
  end, { buffer = game.bufnr, desc = "Show a sudoku tip" })

  vim.keymap.set({ "n" }, "gc", function()
    handleClear(game)
    ui.render(game)
  end, { buffer = game.bufnr, desc = "Clear Sudoku board" })

  vim.keymap.set({ "n" }, "gz", function()
    setViewState(game, "zen")
  end, { buffer = game.bufnr, desc = "Clear Sudoku board" })

  vim.keymap.set({ "n" }, "gs", function()
    setViewState(game, "settings");
  end, { buffer = game.bufnr, desc = "Clear Sudoku board" })

  vim.keymap.set({ "n" }, "x", function()
    if game.viewState == "settings" then
      settings.handleToggleSetting(game)
    end
    handleDelete(game)
    ui.render(game)
  end, { buffer = game.bufnr, desc = "Clear Sudoku board" })

  for i = 1, 9 do
    vim.keymap.set({ "n" }, "r" .. tostring(i), function()
      handleInsert(game, i)
    end, { buffer = game.bufnr, desc = "Insert " .. i .. " into sudoku" })
  end

  nvim.nvim_create_autocmd("CursorMoved", {
    group = vim.api.nvim_create_augroup("render-asd", { clear = true }),
    callback = function()
      ui.render(game)
    end,
  })

  ui.render(game)

end

return M
