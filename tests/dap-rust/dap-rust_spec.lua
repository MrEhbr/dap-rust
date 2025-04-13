-- Mock all the dap modules needed
local mock_dap_utils = {
  pick_process = function()
    return 1234
  end,
}

local mock_dap_ui = {
  pick_one = function(_, _, _)
    return "selected"
  end,
  pick_one_sync = function(_, _, _)
    return "selected"
  end,
}

local mock_dap = {
  adapters = {},
  configurations = {},
  utils = mock_dap_utils,
  ui = mock_dap_ui,
  ABORT = "ABORT",
}

-- Mock the modules
package.loaded["dap"] = mock_dap
package.loaded["dap.utils"] = mock_dap_utils
package.loaded["dap.ui"] = mock_dap_ui

-- Mock system function
local original_system = vim.fn.system
vim.fn.system = function(cmd)
  if type(cmd) == "table" and cmd[1] == "cargo" then
    return [[{"target_directory":"/tmp/target","packages":[{"targets":[{"kind":["bin"],"name":"test_app"}]}]}]]
  elseif cmd == "rustc --print sysroot" then
    return "/usr/local/rustc"
  end
  return original_system(cmd)
end

-- Mock io.open
local original_open = io.open
io.open = function(file, mode)
  if file:find("lldb_commands") then
    return {
      lines = function()
        return { "command" }
      end,
      close = function() end,
    }
  end
  return original_open(file, mode)
end

local dap_rust = require("dap-rust")

describe("setup", function()
  before_each(function()
    -- Reset mocks before each test
    mock_dap.adapters = {}
    mock_dap.configurations = {}
  end)

  it("works with default config", function()
    assert(dap_rust.setup, "setup function exists")
    -- Call setup with required parameters since they're now validated
    dap_rust.setup({
      codelldb = {
        path = "mock_path",
        lib_path = "mock_lib_path",
      },
    })
    -- Verify that dap got configured
    assert(mock_dap.adapters.rust, "rust adapter was registered")
    assert(mock_dap.configurations.rust, "rust configurations were registered")
  end)

  it("works with custom config", function()
    local custom_config = {
      codelldb = {
        path = "custom_path",
        lib_path = "custom_lib_path",
        port = "1234",
      },
    }
    dap_rust.setup(custom_config)
    -- Check that dap got configured with custom settings
    assert(mock_dap.adapters.rust, "rust adapter was registered with custom config")
    assert(mock_dap.configurations.rust, "rust configurations were registered with custom config")
  end)
end)

describe("helper functions", function()
  it("has get_arguments function", function()
    assert(type(dap_rust.get_arguments) == "function", "get_arguments is exported")
  end)
end)
