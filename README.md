<p align="center">
<img src="./.repo/logo.svg" alt="sudoku.nvim" width="50%" margin="25%"/>
</p>

<p align="center">
    Since using neovim have you become a coding ninja, a keyboard warrior a programming wizard? <br /> 
    Are you so <i>blazingly</i> fast that you now have time to spend outside of your terminal?<br />
    <br />Now presenting: <a href="https://github.com/jim-fx/sudoku.nvim"><code>sudoku.nvim</code></a>
</p>

## Table of Content

-   [Installation](#installation)
-   [Screenshots](#screenshots)
-   [Configuration](#configuration)
-   [Mappings](#mappings)
-   [Commands](#commands)

## Installation

Install with <code><a href="https://github.com/wbthomason/packer.nvim">Packer</a></code>
```lua
use {
  'jim-fx/sudoku.nvim',
  cmd = "Sudoku",
  config = function()
    require("sudoku").setup({
      -- configuration ...
    })
  end
}
```

Install with <code><a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></code>
```lua
{
  'jim-fx/sudoku.nvim',
  cmd = "Sudoku",
  config = function()
    require("sudoku").setup({
      -- configuration ...
    })
  end
}
```

## Screenshots
|                                                                                                                                                        |                                                                                                                                                  |                                                                                                                                        |
| :----------------------------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------: |
|           <img alt="Main window" src="./.repo/render_04.jpg">           |                 <img src="./.repo/render_05.jpg">                 | |

## Configuration

```lua
-- These are the defaults for the settings
require("sudoku").setup({
  persist_settings = true, -- safe the settings under vim.fn.stdpath("data"), usually ~/.local/share/nvim,
  persist_games = true, -- persist a history of all played games
  default_mappings = true, -- if set to false you need to set your own, like the following:
  mappings = {
      { key = "x",     action = "clear_cell" },
      { key = "r1",    action = "insert=1" },
      { key = "r2",    action = "insert=2" },
      { key = "r3",    action = "insert=3" },
      -- ...
      { key = "r9",    action = "insert=9" },
      { key = "gn",    action = "new_game" },
      { key = "gr",    action = "reset_game" },
      { key = "gs",    action = "view=settings" },
      { key = "gt",    action = "view=tip" },
      { key = "gz",    action = "view=zen" },
      { key = "gh",    action = "view=help" },
      { key = "u",     action = "undo" },
      { key = "<C-r>", action = "redo" },
      { key = "+",     action = "increment" },
      { key = "-",     action = "decrement" },
  },
  custom_highlights = {
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
})
```

## Mappings

You can see all the default mappings in the configuration settings. If you want to define your own you can either do it with the config, for example if you would like to use `c` to clear a cell you would set:

```lua
require("sudoku").setup({
    mappings = {
        { key = "c", action = "clear_cell" }
    }
})
```

You can also just use `vim.keymap.set` (this will create keymaps for all buffers, not just for the ones that contain the sudoku board)

```lua
vim.keymap.set("n", "c", ":Sudoku clear_cell")
-- or
vim.keymap.set("n", "c", function() require("sudoku").setCell(0) end)
```

   
> [!TIP]
> You could add the following mappings to make it easier to jump between squares
> ```lua
> -- ftplugin/sudoku.lua
> vim.keymap.set("n", "<C-l>", "8l")
> vim.keymap.set("n", "<C-h>", "8h")
> vim.keymap.set("n", "<C-k>", "4k")
> vim.keymap.set("n", "<C-j>", "4j")
> ```

## Commands

All the actions you can see in the default mappings are also available as commands, eg:

```vim
:Sudoku insert=1
:Sudoku insert=2
...
:Sudoku insert=3
:Sudoku new_game
:Sudoku view=help
:Sudoku view=settings
:Sudoku view=tip
:Sudoku reset_game
```

