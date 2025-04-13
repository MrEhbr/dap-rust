# DAP-Rust: Debug Adapter Protocol for Rust in Neovim

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/MrEhbr/dap-rust.nvim/lint-test.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

A Neovim plugin that provides Debug Adapter Protocol (DAP) integration for Rust projects.

## Features

- Debug Rust applications using CodeLLDB
- Support for debugging with arguments
- Automatically detect Rust binaries in your workspace
- Type pretty-printing support for Rust types

## Requirements

- Neovim >= 0.5.0
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "MrEhbr/dap-rust.nvim",
  dependencies = { "mfussenegger/nvim-dap" },
  config = function()
    require("dap-rust").setup({
      -- Required configuration
      codelldb = {
        path = "path/to/codelldb", -- REQUIRED: Path to the CodeLLDB executable
        lib_path = "path/to/liblldb.so", -- REQUIRED: Path to liblldb
        port = "${port}" -- Port for communication, keep as "${port}" to use random port
      },
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "MrEhbr/dap-rust.nvim",
  requires = { "mfussenegger/nvim-dap" },
  config = function()
    require("dap-rust").setup({
      -- Optional custom configuration
    })
  end
}
```

## Configuration

The default configuration requires you to provide the paths to the CodeLLDB executable and liblldb library:

```lua
local default_config = {
  codelldb = {
    path = "", -- REQUIRED: Path to the CodeLLDB executable
    lib_path = "", -- REQUIRED: Path to the liblldb shared library
    port = "${port}",
    args = {},
  },
  tests = {
    verbose = false,
  },
}
```

### Required Parameters

- `codelldb.path`: Path to the CodeLLDB executable
- `codelldb.lib_path`: Path to the liblldb shared library

These paths vary depending on your system and installation method. For example:

#### macOS (with Homebrew)

```lua
path = "/opt/homebrew/opt/llvm/bin/lldb-vscode", 
lib_path = "/opt/homebrew/opt/llvm/lib/liblldb.dylib",
```

#### Linux

```lua
path = "/usr/bin/lldb-vscode",
lib_path = "/usr/lib/liblldb.so",
```

#### Windows

```lua
path = "C:\\Program Files\\LLVM\\bin\\lldb-vscode.exe",
lib_path = "C:\\Program Files\\LLVM\\bin\\liblldb.dll",
```

## Usage

Once configured, you can use nvim-dap commands to debug your Rust applications:

```lua
-- Start debugging with the default configuration
:lua require('dap').continue()

-- Set breakpoints
:lua require('dap').toggle_breakpoint()

-- Step over/into/out
:lua require('dap').step_over()
:lua require('dap').step_into()
:lua require('dap').step_out()
```

## Acknowledgements

This plugin is highly inspired by [nvim-dap-go](https://github.com/leoluz/nvim-dap-go) by [leoluz](https://github.com/leoluz). Many thanks for the excellent work that served as a foundation for this project.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
