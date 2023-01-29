<p align="center">
<img src="https://raw.githubusercontent.com/jim-fx/sudoku.nvim/main/.repo/logo.svg?token=GHSAT0AAAAAAB52IBTQVAX3GWH7MTDH3JCAY6WZLFQ" alt="sudoku.nvim" width="50%" margin="25%"/>
</p>

<p align="center">
    Since using neovim have you become a coding ninja, a keyboard warrior a programming wizard? <br /> 
    Are you so fast that you now have time to spend outside of your terminal?<br />
    <br />Now presenting: <a href="https://github.com/jim-fx/sudoku.nvim"><code>sudoku.nvim</code></a>
</p>

# Table of Contents

-   [Installation](#installation)
-   [Screenshots](#screenshots)
-   [Configuration](#configuration)
-   [Contributing](#contributing)

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
|           <img alt="Main window" src="https://raw.githubusercontent.com/jim-fx/sudoku.nvim/main/.repo/render_04.jpg?token=GHSAT0AAAAAAB52IBTQZVJIYPGRMPJN36BSY6WZLDQ">           |                 <img src="https://raw.githubusercontent.com/jim-fx/sudoku.nvim/main/.repo/render_05.jpg?token=GHSAT0AAAAAAB52IBTRW7KDPHCXGN7KBK2IY6WZOIQ">                 | |

## Configuration

```lua
-- These are the defaults for the settings
require("sudoku").setup({
  persist_settings = true, -- safe the settings under vim.fn.stdpath("data"), usually ~/.local/share/nvim,
  default_mappings = true, -- if set to false you need to set your own,
})
```

