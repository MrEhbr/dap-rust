---@class CustomModule
local M = {}

local default_config = {
  codelldb = {
    path = "",
    lib_path = "",
    port = "${port}",
    args = {},
  },
  tests = {
    verbose = false,
  },
}

local internal_global_config = {}

local function load_module(module_name)
  local ok, module = pcall(require, module_name)
  assert(ok, string.format("dap-rust: dependency error: %s not installed", module_name))
  return module
end

local function get_arguments()
  return coroutine.create(function(dap_run_co)
    local args = {}
    vim.ui.input({ prompt = "Args: " }, function(input)
      args = vim.split(input or "", " ")
      coroutine.resume(dap_run_co, args)
    end)
  end)
end

local function add_rust_types_support()
  -- Find out where to look for the pretty printer Python module
  local rustc_sysroot = vim.fn.trim(vim.fn.system("rustc --print sysroot"))

  local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
  local commands_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_commands"

  local commands = {}
  local file = io.open(commands_file, "r")
  if file then
    for line in file:lines() do
      table.insert(commands, line)
    end
    file:close()
  end
  table.insert(commands, 1, script_import)

  return commands
end

local function setup_codelldb_adapter(dap, config)
  local codelldb_config = {
    type = "server",
    port = config.codelldb.port,
    host = "127.0.0.1",
    executable = {
      command = config.codelldb.path,
      args = { "--liblldb", config.codelldb.lib_path, "--port", config.codelldb.port },
    },
  }

  dap.adapters.rust = function(callback, client_config)
    if client_config.port == nil then
      callback(codelldb_config)
      return
    end

    codelldb_config.port = client_config.port

    callback(codelldb_config)
  end
end

local function pick_one(targets)
  local co, ismain = coroutine.running()
  local ui = require("dap.ui")
  local pick = (co and not ismain) and ui.pick_one or ui.pick_one_sync
  local result = pick(targets, "Select target: ", function(v)
    local target = vim.fn.fnamemodify(v, ":t")
    return target
  end)
  return result or require("dap").ABORT
end

local function get_program()
  local metadata_json = vim.fn.system("cargo metadata --format-version 1 --no-deps")
  local metadata = vim.fn.json_decode(metadata_json)
  local target_dir = metadata.target_directory

  local results = {}
  for _, package in ipairs(metadata.packages) do
    for _, target in ipairs(package.targets) do
      if vim.tbl_contains(target.kind, "bin") then
        table.insert(results, target_dir .. "/debug/" .. target.name)
      end
    end
  end

  return pick_one(results)
end

local function setup_rust_configuration(dap, configs)
  local common_debug_configs = {
    {
      type = "rust",
      name = "Debug",
      request = "launch",
      program = get_program,
      outputMode = configs.codelldb.output_mode,
      initCommands = add_rust_types_support,
    },
    {
      type = "rust",
      name = "Debug (Arguments)",
      request = "launch",
      program = get_program,
      args = get_arguments,
      outputMode = configs.codelldb.output_mode,
      initCommands = add_rust_types_support,
    },
    {
      type = "rust",
      name = "Attach",
      mode = "local",
      request = "attach",
      pid = require("dap.utils").pick_process,
      initCommands = add_rust_types_support,
    },
  }

  if dap.configurations.rust == nil then
    dap.configurations.rust = {}
  end

  for _, config in ipairs(common_debug_configs) do
    table.insert(dap.configurations.rust, config)
  end

  if configs == nil or configs.dap_configurations == nil then
    return
  end

  for _, config in ipairs(configs.dap_configurations) do
    if config.type == "rust" then
      table.insert(dap.configurations.rust, config)
    end
  end
end

function M.setup(opts)
  internal_global_config = vim.tbl_deep_extend("force", default_config, opts or {})

  -- Validate required parameters
  if not internal_global_config.codelldb.path or internal_global_config.codelldb.path == "" then
    error("dap-rust: codelldb.path is required. Please set the path to the CodeLLDB executable.")
  end

  if not internal_global_config.codelldb.lib_path or internal_global_config.codelldb.lib_path == "" then
    error("dap-rust: codelldb.lib_path is required. Please set the path to the liblldb.so library.")
  end

  local dap = load_module("dap")
  setup_codelldb_adapter(dap, internal_global_config)
  setup_rust_configuration(dap, internal_global_config)
end

function M.get_arguments()
  return get_arguments()
end

return M
