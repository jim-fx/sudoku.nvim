<p align="center">
<img src="./.repo/logo.svg" alt="sudoku.nvim" width="50%" margin="25%"/>
</p>

<p align="center">
    Since using neovim have you become a coding ninja, a keyboard warrior a programming wizard? <br /> 
    Are you so fast that you now have time to spend outside of your terminal?<br />
    <br />Now presenting: <a href="https://github.com/jim-fx/sudoku.nvim"><code>sudoku.nvim</code></a>
</p>

-   [Installation](#installation)
-   [Screenshots](#screenshots)
-   [Configuration](#configuration)

## Installation

Install with <code><a href="https://github.com/wbthomason/packer.nvim">Packer</a></code>
```lua
use {
  'jim-fx/sudoku.nvim'
}
```

Install with <code><a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></code>
```lua
{
  'jim-fx/sudoku.nvim',
  cmd = "Sudoku",
  config = true
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
  default_mappings = true, -- if set to false you need to set your own,
})
```

