-- main module file
local module = require("dap-rust.module")

---@class Config
---@field codelldb table Configuration for codelldb adapter
---@field codelldb.path string REQUIRED: Path to the CodeLLDB executable
---@field codelldb.lib_path string REQUIRED: Path to the liblldb shared library
---@field codelldb.port string Port for communication with the debug adapter
---@field codelldb.args table Additional arguments for the adapter
---@field tests table Configuration for tests
---@field dap_configurations table? Additional DAP configurations
local config = {
  codelldb = {
    path = "", -- REQUIRED: must be set by user
    lib_path = "", -- REQUIRED: must be set by user
    port = "${port}",
    args = {},
  },
}

---@class DapRust
local M = {}

---@type Config
M.config = config

---@param args Config?
-- Setup function for dap-rust
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
  module.setup(M.config)
end

-- Expose helper functions
M.get_arguments = module.get_arguments

return M
