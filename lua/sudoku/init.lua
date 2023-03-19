local options   = require("sudoku.options")
local ui        = require("sudoku.ui")
local core      = require("sudoku.core")
local settings  = require("sudoku.settings")
local events    = require("sudoku.events")
local history   = require("sudoku.history")
local constants = require("sudoku.constants")

---@class Game
---@field bufnr number
---@field ns number
---@field board Board
---@field boards Board[]
---@field viewState ViewState
---@field settings Settings
---@field __debug boolean

local M         = {}

local games     = {}
local function findActiveGame(bufnr)
  if bufnr == nil then
    bufnr = vim.api.nvim_get_current_buf();
  end

  for _, game in pairs(games) do
    if game.bufnr == bufnr then
      return game
    end
  end
  return nil
end

M.createNewBoard = function()
  local game = findActiveGame();

  if game == nil then
    local buf = ui.createNewBuffer();

    game = {
      bufnr = buf,
      ns = constants.namespace,
      board = nil,
      viewState = "normal",
      boards = {},
      settings = settings.readSettings()
    };

    table.insert(games, game);

    core.createNewBoard(game)

    events.setup(game);
  end

  return game;
end


local function handleCommand(cmd)
  local command = cmd.args;

  if command == "" then
    M.createNewBoard()
  else
    local game = findActiveGame();
    if game == nil then
      print("No active game")
      return
    end
    events.handleAction(game, command);
  end
end

---Resets the board in the currently active buffer
M.resetBoard = function(bufnr)
  local game = findActiveGame(bufnr);
  if game == nil then
    return
  end
  core.resetBoard(game.board)
  ui.render(game)
end

M.insert = function(value, opts)
  local _opts = (opts == nil) and {} or opts
  if _opts.bufnr == nil then
    _opts.bufnr = vim.api.nvim_get_current_buf();
  end

  local game = findActiveGame(_opts.bufnr);
  if game == nil then
    return
  end

  ---@type Cell
  local cell;
  if _opts.index ~= nil then
    cell = core.getCell(game.board, _opts.index);
  elseif _opts.x ~= nil and _opts.y ~= nil then
    cell = core.getCell(game.board, _opts.x, _opts.y);
  else
    cell = core.getCursorCell(game.board)
  end

  if cell == nil then
    print("Invalid cell position, you need to specify either (x and y) or index")
    return
  end

  local cellIndex = _opts.index and _opts.index or core.getCellIndex(game.board, cell) --[[@as number]];

  if cell == nil then
    print("Invalid cell position, no cell found for specified position " ..
      (_opts.index and "{ index=" .. _opts.index .. " }" or "{ x=" .. _opts.x .. ", y=" .. _opts.y .. "}"))
    return
  end

  core.setCellValue(game.board, cellIndex, value);

  ui.render(game)
end

---Undo the last move
---@param bufnr number? #optionally define the bufnr of the sudoku game
M.undo = function(bufnr)
  local game = findActiveGame(bufnr);
  if game == nil then
    return
  end

  history.undoBoardStep(game.board)

  ui.render(game)
end

M.clearCell = function()
  local game = findActiveGame();
  if game == nil then
    return
  end

  core.setCursorCellValue(game.board, 0)

  ui.render(game);
end

---Redo the last move
---@param bufnr number? #optionally define the bufnr of the sudoku game
M.redo = function(bufnr)
  local game = findActiveGame(bufnr);
  if game == nil then
    return
  end

  history.redoBoardStep(game.board)

  ui.render(game)
end

---@param opts Options
M.setup = function(opts)
  options.set(opts);

  local completions = {}
  for key in pairs(events.actions) do
    table.insert(completions, key)
  end

  vim.api.nvim_create_user_command("Sudoku", handleCommand, {
    nargs = "?",
    complete = function(cmd)
      local _comp = {};
      for _, value in ipairs(completions) do
        if string.find(value, cmd) then
          table.insert(_comp, value)
        end
      end
      return _comp
    end
  })
end

return M
