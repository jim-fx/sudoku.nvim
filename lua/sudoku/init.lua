local game    = require("sudoku.game")
local options = require("sudoku.options")
local events  = require("sudoku.events")

local M = {}

---@param opts Options
M.setup = function(opts)

  options.set(opts);

  vim.api.nvim_create_user_command("Sudoku", game.init, {
    nargs = "?",
    complete = function()
      return events.actions
    end
  })
end

return M
