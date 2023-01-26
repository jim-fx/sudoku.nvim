local renderer = require("sudoku.renderer")
local util = require("sudoku.util")
local core = require("sudoku.core")
local settings = require("sudoku.settings")
local nvim = vim.api

local M = {}

-- highlight line that contains utf8 characters column wise
local function highlightLine(game, group, y, x1, x2)

  local line = vim.api.nvim_buf_get_lines(game.bufnr, y, y + 1, false)[1]
  if line == nil then
    return
  end

  local _x1 = vim.str_byteindex(line, x1, false);
  local _x2 = vim.str_byteindex(line, x2, false);

  vim.api.nvim_buf_add_highlight(game.bufnr, game.ns, group, y, _x1, _x2)

end

local function drawWin(game)

  local board = game.board;

  local endTime = os.time()
  local diff = os.difftime(endTime, board.startTime);
  local difficulty = {
    "easy",
    "medium",
    "hard"
  }

  return {
    "You have solved the Sudoku!",
    "",
    "Time: " .. string.format("%.2d:%.2d:%.2d", diff / (60 * 60), diff / 60 % 60, diff % 60),
    "Difficulty: " .. difficulty[board.difficulty],
    "Tips: " .. board.tips,
  }
end

local function drawUI(game)

  local viewState = game.viewState;
  local lines = {
    "",
    " Sudoku",
    "╭───────────────╮",
    "│ [gr] restart " .. (viewState == "restart" and "-" or " ") .. "│",
    " ├───────────────┤",
    "│ [gh] help    " .. (viewState == "help" and "-" or " ") .. "│",
    "├───────────────┤",
    "│ [gt] tip     " .. (viewState == "tip" and "-" or " ") .. "│",
    " ├───────────────┤",
    "│ [gs] settings" .. (viewState == "settings" and "-" or " ") .. "│",
    "╰───────────────╯"
  }

  return lines
end

local function drawHelp()
  return {
    "Sudoku Rules: ",
    "1. Each row must contain the numbers 1-9",
    "2. Each column must contain the numbers 1-9",
    "3. Each 3x3 box must contain the numbers 1-9",
    "",
    "Keymappings:",
    "[g1..g9] -> Insert a number",
    "[x]    -> Clear a cell",
    "[gr]   -> Start a new game",
    "[gh]   -> Show help",
    "[gt]   -> Show a tip",
    "[gs]   -> Show settings",
    "[gc]   -> Clear board",
    "[gz]   -> Zen Mode"
  }
end

local function drawRestart(game)

  local board = game.board;

  local changedCells = 0;
  for i = 1, 81 do
    local cell = board.cells[i]
    if cell.set ~= 0 then
      changedCells = changedCells + 1
    end
  end

  return {
    "You have changed " .. changedCells .. " cell" ..
        (changedCells > 1 and "s" or "") .. ", are you sure you want to reset?",
    "[r]estart [n]o"
  }
end

local function drawCellCandidates(game)

  local cell = core.getCursorCell(game);

  if cell == nil then
    return {}
  end

  local canidateLine = "Cell Candidates: "

  for i = 1, 9 do
    if cell.candidates[i] then
      canidateLine = canidateLine .. i .. " "
    end
  end

  return { canidateLine }

end

local function drawNumbersLeft(game)

  local numbersLeft = {};
  local board = game.board;

  for i = 1, 9 do
    numbersLeft[i] = 9
  end

  for i = 1, 81 do
    local cell = board.cells[i]
    local cellValue = cell.show and cell.number or cell.set;
    if cellValue ~= 0 then
      numbersLeft[cellValue] = numbersLeft[cellValue] - 1
    end
  end

  local numbersLeftStr = "Numbers left: "

  for i = 1, 9 do
    if numbersLeft[i] ~= 0 then
      numbersLeftStr = "" .. numbersLeftStr .. "" .. i .. " "
    end
  end

  return { numbersLeftStr }
end

M.render = function(game)
  local board = game.board;

  local lines = renderer.renderBoard(board);
  local isValid = core.checkBoardValid(board) and "valid" or "invalid";

  if game.viewState == "normal" then
    if game.settings.showNumbersLeft then
      util.tableConcat(lines, drawNumbersLeft(game))
    end

    if game.settings.showCandidates then
      util.tableConcat(lines, drawCellCandidates(game))
    end
  end

  if game.viewState ~= "zen" then
    local ui = drawUI(game)
    for i = 1, #ui do
      lines[i] = lines[i] .. "" .. ui[i]
    end
    game.__zenTimer = nil
  else
    if game.__zenTimer ~= 0 then
      lines = util.tableConcat(lines, { "ZenMode ([gz] to leave)" })
    end
    if game.__zenTimer == nil then
      game.__zenTimer = vim.loop.new_timer()
      game.__zenTimer:start(2000, 0, function()
        game.__zenTimer = 0;
      end)
    end
  end

  local missingCells = core.totalMissingCells(board);
  if missingCells == 0 then
    lines = util.tableConcat(lines, drawWin(game));
  end

  if game.viewState == "tip" then

    local tipCell = nil;
    for i = 1, 81 do
      local cell = board.cells[i]
      if cell.set == 0 then
        tipCell = cell;
        break;
      end
    end

    if tipCell ~= nil then
      lines = util.tableConcat(lines, { "There is only one possible number", "that fits in the highlighted cell." });
    end

  end


  if game.viewState == "restart" then
    lines = util.tableConcat(lines, drawRestart(game));
  end

  if game.viewState == "help" then
    lines = util.tableConcat(lines, drawHelp());
  end

  if game.viewState == "settings" then
    lines = util.tableConcat(lines, settings.drawSettings(game));
  end

  if game.__debug then
    lines = util.tableConcat(lines, { "Board is " .. isValid });
    lines = util.tableConcat(lines, { "Missing cells: " .. missingCells });

    local x, y = util.getPos();
    lines = util.tableConcat(lines, { "Cursor x: " .. x + 1 .. " y: " .. y + 1 });

    local cell = core.getCell(board, x + 1, y + 1);
    if cell ~= nil then

      local cellLine = "cell: " .. cell.number or cell.set;


      if cell.errors ~= nil then
        for _, value in pairs(cell.errors) do
          cellLine = cellLine .. " " .. value
        end
      end

      lines = util.tableConcat(lines, { cellLine });

    end

    lines = util.tableConcat(lines, { "viewState: " .. game.viewState });

    if x ~= -1 and y ~= -1 and cell ~= nil then
      local candidates = cell.candidates;
      local candidateLine = "";
      for i = 1, 9 do
        candidateLine = candidateLine .. (candidates[i] == true and i or "x") .. " "
      end
      candidateLine = "Candidates: " .. candidateLine .. " #" .. util.tableLength(candidates)
      lines = util.tableConcat(lines, { candidateLine });
    end

  end

  nvim.nvim_buf_set_option(game.bufnr, "modifiable", true)
  nvim.nvim_buf_set_lines(game.bufnr, 0, -1, false, lines)
  nvim.nvim_buf_set_option(game.bufnr, "modifiable", false)

  M.highlight(game)
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


M.highlight = function(game)

  local board = game.board;
  nvim.nvim_buf_clear_namespace(game.bufnr, game.ns, 0, -1)

  vim.cmd("hi SudokuBoard guifg=#8a8a8a")
  vim.cmd("hi SudokuNumber ctermfg=white ctermbg=black guifg=white guibg=black")
  vim.cmd("hi SudokuActiveMenu gui=bold")
  vim.cmd("hi SudokuHintCell ctermbg=yellow guibg=yellow")
  vim.cmd("hi SudokuSquare guibg=#292b35 guifg=#ffffff");
  vim.cmd("hi SudokuColumn guibg=#14151a guifg=#d5d5d5");
  vim.cmd("hi SudokuRow guibg=#14151a guifg=#d5d5d5");
  vim.cmd("hi SudokuSettingsDisabled gui=italic guifg=#8e8e8e");
  vim.cmd("hi SudokuSameNumber gui=bold guifg=white");
  vim.cmd("hi SudokuError guibg=#843434");

  local x, y = util.getPos();

  local cy = vim.fn.line(".")
  local cx = vim.fn.virtcol(".")

  local sett = game.settings;

  if sett.highlight.enabled then
    for i = 1, 9 do
      for j = 1, 3 do
        local sx = (j - 1) * 8 + 1;
        local sy = i + math.floor((i - 1) / 3);
        highlightLine(game, "SudokuBoard", sy, sx, sx + 7);
      end
    end
  end

  -- highlight side buttons
  if game.viewState ~= "normal" then
    if game.viewState == "settings" then
      highlightLine(game, "SudokuActiveMenu", 9, 27, 42);
      -- highlight active line
      if cy > 14 then
        highlightLine(game, "Visual", cy - 1, 0, -1);
      end

      if game.settings.highlight.enabled == false then
        for i = 1, 5 do
          highlightLine(game, "SudokuSettingsDisabled", 20 + i, 0, -1);
        end
      end

    end
    if game.viewState == "help" then
      highlightLine(game, "SudokuActiveMenu", 5, 27, 42);
    end
    if game.viewState == "restart" then
      highlightLine(game, "SudokuActiveMenu", 3, 27, 42);
    end
    if game.viewState == "tip" then
      highlightLine(game, "SudokuActiveMenu", 7, 27, 42);
    end
  end

  -- highlight cell if tip
  if game.viewState == "tip" then
    for i = 1, 81 do
      local cell = board.cells[i]
      if cell.tip then
        local _cx, _cy = core.indexToPosition(i);
        local sx = _cx * 2 + math.floor((_cx - 1) / 3) * 2;
        local sy = _cy + math.floor((_cy / 4));
        if sy == 8 then
          sy = 9
        end
        highlightLine(game, "SudokuHintCell", sy, sx, sx + 1);
      end
    end
  end


  -- highlight current row
  if y ~= -1 and sett.highlight.enabled and sett.highlight.row then
    highlightLine(game, "SudokuRow", cy - 1, 1, 24);
  end


  -- highlight invalid cells
  if sett.highlight.enabled and sett.highlight.errors then
    for i = 1, 81 do
      local cell = board.cells[i]
      if cell.__invalid then
        local _cx, _cy = core.indexToPosition(i);
        local sx = _cx * 2 + math.floor((_cx - 1) / 3) * 2;
        local sy = _cy + math.floor((_cy / 4));
        if sy == 8 then
          sy = 9
        end
        highlightLine(game, "SudokuError", sy, sx, sx + 1);
      end
    end
  end

  if x ~= -1 and y ~= -1 and cx < 25 and cy < 14 then
    -- highlight current column
    if sett.highlight.enabled and sett.highlight.column then
      for i = 1, 11 do
        highlightLine(game, "SudokuColumn", i, cx - 1, cx);
      end
    end


    -- highlight same numbers
    if sett.highlight.enabled and sett.highlight.sameNumber then
      local cell = core.getCell(board, x + 1, y + 1)
      local cellValue = cell.show and cell.number or cell.set;
      if cellValue ~= nil and cellValue ~= 0 then
        for i = 1, 81 do
          local c = board.cells[i]
          local cellValueMatches = cellValue == (c.show and c.number or c.set);
          if cellValueMatches then
            local _cx, _cy = core.indexToPosition(i);
            local sx = _cx * 2 + math.floor((_cx - 1) / 3) * 2;
            local sy = _cy + math.floor((_cy / 4));
            if sy == 8 then
              -- no idea why this is needed
              sy = 9
            end
            highlightLine(game, "SudokuSameNumber", sy, sx, sx + 1);
          end
        end
      end
    end

  end

  -- highlight square
  if sett.highlight.enabled and sett.highlight.square then
    if y ~= -1 and cx < 25 then
      local sx = math.floor((cx - 1) / 8) * 8 + 1;
      local sy = math.floor((cy - 1) / 4) * 4;
      for i = 1, 3 do
        highlightLine(game, "SudokuSquare", sy + i, sx, sx + 7);
      end
    end
  end


end


return M
