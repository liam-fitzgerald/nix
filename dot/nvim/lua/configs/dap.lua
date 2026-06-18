
local dap = require("dap")

dap.adapters.lldb = {
  type = "executable",
  command = "/etc/profiles/per-user/test/bin/lldb-dap",
  name = "lldb"
}

require("dapui").setup()

-- Auto-open/close on debug start/end
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
