local core = require("sudoku.core")
local ui = require("sudoku.ui");
local util = require("sudoku.util");
local settings = require("sudoku.settings");

local M = {}
local nvim = vim.api;

local function handleDelete(game)
  local x, y = util.getPos()
  if x ~= -1 and y ~= -1 and x ~= nil and y ~= nil then
    core.clearCell(game.board, x + 1, y + 1)
    ui.render(game)
  end
end

local function handleClear(game)
  local board = game.board;
  for i = 1, 81 do
    board.cells[i].set = 0
    board.cells[i].show = false
    board.cells[i].candidates = {}
    board.cells[i].number = 0
  end
end

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

local function handleRestart(game)

  local changedCells = 0;
  for i = 1, 81 do
    local cell = game.board.cells[i]
    if cell.set ~= 0 then
      changedCells = changedCells + 1
    end
  end

  if game.viewState == "restart" or changedCells == 0 then
    core.createNewBoard(game)
    game.viewState = "normal"
  else
    game.viewState = "restart"
  end

  ui.render(game)
end

M.setup = function(game)

  vim.keymap.set({ "n" }, "+", function()
    handleIncrement(game, 1)
  end, { buffer = game.bufnr })

  vim.keymap.set({ "n" }, "-", function()
    handleIncrement(game, -1)
  end, { buffer = game.bufnr })

  vim.keymap.set({ "n" }, "gh", function()
    game.viewState = (game.viewState == "help") and "normal" or "help"
    ui.render(game)
    settings.writeSettings(game);
  end, { buffer = game.bufnr, desc = "Show sudoku help" })

  vim.keymap.set({ "n" }, "gr", function()
    handleRestart(game)
    settings.writeSettings(game);
  end, { buffer = game.bufnr, desc = "Start a new sudoku board" })

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
      handleRestart(game)
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
    game.viewState = (game.viewState == "zen") and "normal" or "zen";
    ui.render(game)
    settings.writeSettings(game);
  end, { buffer = game.bufnr, desc = "Clear Sudoku board" })

  vim.keymap.set({ "n" }, "gs", function()
    game.viewState = (game.viewState == "settings") and "normal" or "settings"
    ui.render(game)
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
