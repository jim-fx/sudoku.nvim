local game = require("sudoku.game")

local M = {}

local function createNewSudoku()
  game.init();
end

M.setup = function()

  vim.cmd("hi SudokuBoard guifg=#7d7d7d")
  vim.cmd("hi SudokuNumber ctermfg=white ctermbg=black guifg=white guibg=black")
  vim.cmd("hi SudokuActiveMenu gui=bold")
  vim.cmd("hi SudokuHintCell ctermbg=yellow guibg=yellow")
  vim.cmd("hi SudokuSquare guibg=#292b35 guifg=#ffffff");
  vim.cmd("hi SudokuColumn guibg=#14151a guifg=#d5d5d5");
  vim.cmd("hi SudokuRow guibg=#14151a guifg=#d5d5d5");
  vim.cmd("hi SudokuSettingsDisabled gui=italic guifg=#8e8e8e");
  vim.cmd("hi SudokuSameNumber gui=bold guifg=white");
  vim.cmd("hi SudokuSetNumber gui=italic guifg=white");
  vim.cmd("hi SudokuError guibg=#843434");

  vim.api.nvim_create_user_command("Sudoku", createNewSudoku, {})
end

return M
