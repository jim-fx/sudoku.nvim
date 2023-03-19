local options = require("sudoku.options")

local M = {}

local default_highlights = {
  board = { fg = "#7d7d7d" },
  number = { fg = "white", bg = "black" },
  active_menu = { fg = "white", bg = "black", gui = "bold" },
  hint_cell = { fg = "white", bg = "yellow" },
  square = { bg = "#292b35", fg = "white" },
  column = { bg = "#14151a", fg = "#d5d5d5" },
  row = { bg = "#14151a", fg = "#d5d5d5" },
  settings_disabled = { fg = "#8e8e8e", gui = "italic" },
  same_number = { fg = "white", gui = "bold" },
  set_number = { fg = "white", gui = "italic" },
  error = { fg = "white", bg = "#843434" },
}

---@param group HighlightOptions
local function buildHighlight(group)
  local fg = group.fg and "guifg=" .. group.fg or "";
  local bg = group.bg and "guibg=" .. group.bg or "";
  local gui = group.gui and "gui=" .. group.gui or "";
  return fg .. " " .. bg .. " " .. gui;
end

M.createHighlightGroups = function()
  local custom_highlights = options.get("custom_highlights") or {};

  local highlights = {};
  for k, v in pairs(default_highlights) do
    highlights[k] = vim.tbl_extend("force", v, custom_highlights[k] or {});
  end

  vim.cmd("hi SudokuBoard " .. buildHighlight(highlights["board"]))
  vim.cmd("hi SudokuNumber " .. buildHighlight(highlights["number"]))
  vim.cmd("hi SudokuActiveMenu " .. buildHighlight(highlights["active_menu"]))
  vim.cmd("hi SudokuHintCell " .. buildHighlight(highlights["hint_cell"]))
  vim.cmd("hi SudokuSquare " .. buildHighlight(highlights["square"]));
  vim.cmd("hi SudokuColumn " .. buildHighlight(highlights["column"]));
  vim.cmd("hi SudokuRow " .. buildHighlight(highlights["row"]));
  vim.cmd("hi SudokuSettingsDisabled " .. buildHighlight(highlights["settings_disabled"]));
  vim.cmd("hi SudokuSameNumber " .. buildHighlight(highlights["same_number"]));
  vim.cmd("hi SudokuSetNumber " .. buildHighlight(highlights["set_number"]));
  vim.cmd("hi SudokuError " .. buildHighlight(highlights["error"]));
end

return M
