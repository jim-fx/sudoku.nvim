local core     = require("sudoku.core")
local ui       = require("sudoku.ui");
local util     = require("sudoku.util");
local settings = require("sudoku.settings");
local history  = require("sudoku.history")

local M = {}
local nvim = vim.api;

---@enum actions
M.actions = {
  ["insert_1"] = {
    key = "r1",
    description = "Set the value of the cell under the cursor to 1"
  },
  ["insert_2"] = {
    key = "r2",
    description = "Set the value of the cell under the cursor to 2"
  },
  ["insert_3"] = {
    key = "r3",
    description = "Set the value of the cell under the cursor to 3"
  },
  ["insert_4"] = {
    key = "r4",
    description = "Set the value of the cell under the cursor to 4"
  },
  ["insert_5"] = {
    key = "r5",
    description = "Set the value of the cell under the cursor to 5"
  },
  ["insert_6"] = {
    key = "r6",
    description = "Set the value of the cell under the cursor to 6"
  },
  ["insert_7"] = {
    key = "r7",
    description = "Set the value of the cell under the cursor to 7"
  },
  ["insert_8"] = {
    key = "r8",
    description = "Set the value of the cell under the cursor to 8"
  },
  ["insert_9"] = {
    key = "r9",
    description = "Set the value of the cell under the cursor to 9"
  },
  ["clear_cell"] = {
    key = "x",
    description = "Clear the cell under the cursor"
  },
  ["game_new"] = {
    key = "gn",
    description = "New sudoku board"
  },
  ["game_reset"] = {
    key = "gr",
    description = "Reset sudoku board"
  },
  ["game_exit"] = {
    key = "gq",
    description = "Exit game"
  },
  ["view_settings"] = {
    key = "gs",
    description = "Show settings"
  },
  ["view_tip"] = {
    key = "gt",
    description = "Show tip"
  },
  ["view_help"] = {
    key = "gh",
    description = "Show help"
  },
  ["undo"] = {
    key = "u",
    description = "Undo last action"
  },
  ["redo"] = {
    key = "<C-r>",
    description = "Redo last action"
  }
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
  board.history = {
    index = 0,
    steps = {}
  }
end

---Set the cell value under the cursor
---@param game Game
---@param cellValue number
local function handleInsert(game, cellValue)
  local cell = core.setCursorCellValue(game.board, cellValue);
  if cell == nil then
    return
  end
  if cell.tip == true then
    cell.tip = false
    if game.viewState == "tip" then
      game.viewState = "normal"
    end
  end

  ui.render(game)
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

  local cell = core.getCursorCell(game.board)

  if cell == nil then
    return
  end

  local newCellValue = 0;

  if cell.set == nil then
    if number == -1 then
      newCellValue = 9;
    else
      newCellValue = 1;
    end
  elseif cell.set == 9 and number == 1 then
    newCellValue = 1;
  elseif cell.set == 1 and number == -1 then
    newCellValue = 9;
  else
    newCellValue = cell.set + number;
  end
  core.setCursorCellValue(game.board, newCellValue);

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
      if c.entropy == 1 and c.show == false and c.set ~= 0 then
        cell = c
        vim.notify(vim.inspect(cell));
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

---@param game Game
local function handleMouseClick(game)
  local mousePos = vim.fn.getmousepos();
  local winId = mousePos.winid
  local col = mousePos.column
  local row = mousePos.line

  if game.viewState == "normal" then
    if mousePos.line == 14 then
      handleInsert(game, math.floor(col / 2) + 1);
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
  end, { buffer = game.bufnr, desc = "Insert clicked number" })

  vim.keymap.set({ "n" }, "gd3b", function()
    game.__debug = not game.__debug
    ui.render(game)
  end, { buffer = game.bufnr, desc = "Enter secret d3bug mode" })

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
  end, { buffer = game.bufnr, desc = "Enter sudoku zen mode" })

  vim.keymap.set({ "n" }, "gs", function()
    setViewState(game, "settings");
  end, { buffer = game.bufnr, desc = "Enter sudoku settings mode" })

  vim.keymap.set({ "n" }, "u", function()
    history.undoBoardStep(game.board);
    ui.render(game)
  end, { buffer = game.bufnr, desc = "Undo board step" })

  vim.keymap.set({ "n" }, "<C-r>", function()
    history.redoBoardStep(game.board);
    ui.render(game)
  end, { buffer = game.bufnr, desc = "Redo board step" })

  vim.keymap.set({ "n" }, "x", function()
    if game.viewState == "settings" then
      settings.handleToggleSetting(game)
    end
    handleDelete(game)
    ui.render(game)
  end, { buffer = game.bufnr, desc = "Clear sudoku cell" })

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
