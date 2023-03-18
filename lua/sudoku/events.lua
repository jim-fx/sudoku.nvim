local core     = require("sudoku.core")
local ui       = require("sudoku.ui");
local util     = require("sudoku.util");
local settings = require("sudoku.settings");
local history  = require("sudoku.history")
local options  = require("sudoku.options")

local M = {}
local nvim = vim.api;

---@enum actions
M.actions = {
  ["insert=1"] = {
    key = "r1",
    description = "Set the value of the cell under the cursor to 1"
  },
  ["insert=2"] = {
    key = "r2",
    description = "Set the value of the cell under the cursor to 2"
  },
  ["insert=3"] = {
    key = "r3",
    description = "Set the value of the cell under the cursor to 3"
  },
  ["insert=4"] = {
    key = "r4",
    description = "Set the value of the cell under the cursor to 4"
  },
  ["insert=5"] = {
    key = "r5",
    description = "Set the value of the cell under the cursor to 5"
  },
  ["insert=6"] = {
    key = "r6",
    description = "Set the value of the cell under the cursor to 6"
  },
  ["insert=7"] = {
    key = "r7",
    description = "Set the value of the cell under the cursor to 7"
  },
  ["insert=8"] = {
    key = "r8",
    description = "Set the value of the cell under the cursor to 8"
  },
  ["insert=9"] = {
    key = "r9",
    description = "Set the value of the cell under the cursor to 9"
  },
  ["clear_cell"] = {
    key = "x",
    description = "Clear the cell under the cursor"
  },
  ["new_game"] = {
    key = "gn",
    description = "New sudoku board"
  },
  ["cancel_new_game"] = {
    key = "gc",
    description = "Cancel new game"
  },
  ["reset_game"] = {
    key = "gr",
    description = "Reset sudoku board"
  },
  ["exit"] = {
    key = "gq",
    description = "Exit game"
  },
  ["view=settings"] = {
    key = "gs",
    description = "Show settings"
  },
  ["view=tip"] = {
    key = "gt",
    description = "Show tip"
  },
  ["view=help"] = {
    key = "gh",
    description = "Show help"
  },
  ["view=zen"] = {
    key = "gz",
    description = "Enter zen mode"
  },
  ["undo"] = {
    key = "u",
    description = "Undo last action"
  },
  ["redo"] = {
    key = "<C-r>",
    description = "Redo last action"
  },
  ["increment"] = {
    key = "+",
    description = "Increment the value of the cell under the cursor"
  },
  ["decrement"] = {
    key = "-",
    description = "Decrement the value of the cell under the cursor"
  }
}

---@param game Game
local function handleClear(game)
  local x, y = util.getPos()
  if x ~= -1 and y ~= -1 and x ~= nil and y ~= nil then
    core.clearCell(game.board, x + 1, y + 1)
  end
end

---Clear all cells in the current board
---@param game Game
local function handleReset(game)
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
end

---@param game Game
---@param state ViewState
local function setViewState(game, state)
  game.viewState = (game.viewState == state) and "normal" or state;
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

---@param game Game
---@param actionId string
M.handleAction = function(game, actionId)

  if string.sub(actionId, 0, 6) == "insert" then

    if string.sub(actionId, 0, 7) ~= "insert=" then
      print("Sudoku: insert command requires a number, eg: insert=2")
      return
    end

    local string_value = string.gsub(actionId, "insert=", "")
    local value = tonumber(string_value)
    if value == nil then
      print("Sudoku: insert command requires a number, eg: insert=2")
      return
    end
    value = math.max(1, math.min(value, 9));
    -- convert string to integer:
    handleInsert(game, value);
  elseif string.sub(actionId, 0, 4) == "view" then
    if string.sub(actionId, 0, 5) ~= "view=" then
      print("Sudoku: view command requires a view name, eg: view=help")
    end

    local view = string.gsub(actionId, "view=", "")

    if view == "help" then
      setViewState(game, "help")
    elseif view == "tip" then
      handleShowTip(game)
    elseif view == "settings" then
      setViewState(game, "settings")
    elseif view == "normal" then
      setViewState(game, "normal")
    elseif view == "zen" then
      setViewState(game, "zen")
    else
      print("Sudoku: unknown view: " .. view)
    end

  elseif actionId == "clear_cell" then
    if game.viewState == "settings" then
      settings.handleToggleSetting(game)
    end
    handleClear(game)
  elseif actionId == "new_game" then
    handleNewGame(game)
  elseif actionId == "cancel_new_game" then
    setViewState(game, "normal")
  elseif actionId == "reset_game" then
    handleReset(game)
  elseif actionId == "exit" then
  elseif actionId == "undo" then
    history.undoBoardStep(game.board)
  elseif actionId == "redo" then
    history.redoBoardStep(game.board)
  elseif actionId == "increment" then
    handleIncrement(game, 1)
  elseif actionId == "decrement" then
    handleIncrement(game, -1)
  else
    print("Sudoku: unknown action: " .. actionId)
  end

  ui.render(game)

end

M.setup = function(game)

  local custom_mappings = {};
  for _, value in pairs(options.get("mappings") or {}) do
    custom_mappings[value.action] = value.key;
  end

  for actionId, value in pairs(M.actions) do
    local key = custom_mappings[actionId] and custom_mappings[actionId] or value.key--[[@as string]] ;
    vim.keymap.set({ "n" }, key, function()
      M.handleAction(game, actionId);
    end, { buffer = game.bufnr, desc = value.description })
  end

  vim.keymap.set({ "n" }, "<LeftMouse>", function()
    handleMouseClick(game)
    ui.render(game)
  end, { buffer = game.bufnr, desc = "Insert clicked number" })

  vim.keymap.set({ "n" }, "gd3b", function()
    game.__debug = not game.__debug
    ui.render(game)
  end, { buffer = game.bufnr, desc = "Enter secret d3bug mode" })

  nvim.nvim_create_autocmd("CursorMoved", {
    group = vim.api.nvim_create_augroup("jim-fx/sudoku.nvim", { clear = true }),
    callback = function()
      ui.render(game)
    end,
  })

  ui.render(game)

end

return M
