local M = {}

local function drawCheckBox(bool)
  return bool and "[x]" or "[ ]"
end

M.drawSettings = function(game)

  local settings = game.settings;
  local high = settings.highlight;

  return {
    "(press [x] to toggle)",
    "Difficulty",
    "   " .. drawCheckBox(settings.difficulty == 1) .. " Easy",
    "   " .. drawCheckBox(settings.difficulty == 2) .. " Medium",
    "   " .. drawCheckBox(settings.difficulty == 3) .. " Hard",
    drawCheckBox(settings.showNumbersLeft) .. " Show which numbers are left",
    drawCheckBox(settings.showCandidates) .. " Show candidates for a cell",
    drawCheckBox(high.enabled) .. " Highlighting",
    "   " .. drawCheckBox(high.row) .. " Row",
    "   " .. drawCheckBox(high.column) .. " Column",
    "   " .. drawCheckBox(high.square) .. " Square",
    "   " .. drawCheckBox(high.errors) .. " Errors",
    "   " .. drawCheckBox(high.sameNumber) .. " Same Number",
  }
end

M.handleToggleSetting = function(game)

  local y = vim.fn.line(".")

  if y < 15 then
    return
  end

  if y == 15 then
    game.settings.difficulty = 1 + (game.settings.difficulty + 1) % 3;
  end

  if y == 16 then
    game.settings.difficulty = 1;
  end
  if y == 17 then
    game.settings.difficulty = 2;
  end
  if y == 18 then
    game.settings.difficulty = 3;
  end

  if y == 19 then
    game.settings.showNumbersLeft = not game.settings.showNumbersLeft
  end

  if y == 20 then
    game.settings.showCandidates = not game.settings.showCandidates
  end

  if y == 21 then
    game.settings.highlight.enabled = not game.settings.highlight.enabled
  end

  if y == 22 then
    game.settings.highlight.enabled = true
    game.settings.highlight.row = not game.settings.highlight.row
  end

  if y == 23 then
    game.settings.highlight.enabled = true
    game.settings.highlight.column = not game.settings.highlight.column
  end

  if y == 24 then
    game.settings.highlight.enabled = true
    game.settings.highlight.square = not game.settings.highlight.square
  end

  if y == 25 then
    game.settings.highlight.enabled = true
    game.settings.highlight.errors = not game.settings.highlight.errors
  end

  if y == 26 then
    game.settings.highlight.enabled = true
    game.settings.highlight.sameNumber = not game.settings.highlight.sameNumber
  end



end

return M
