local game = require("sudoku.game")

local M = {}

local games = {}

local function createNewSudoku()
  local newGame = game.init();
  games[newGame.bufnr] = newGame;
end

M.setup = function()


  vim.api.nvim_create_user_command("Sudoku", createNewSudoku, {
    nargs = "?",
    complete = function(_, line)
      vim.notify(line)
      return { "insert", "clear", "restart" }
    end
  })
end

M.insert = function(num)



end

return M
