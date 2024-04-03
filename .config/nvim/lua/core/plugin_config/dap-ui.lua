-- https://github.com/rcarriga/nvim-dap-ui?tab=readme-ov-file#usage
local dap, dapui = require("dap"), require("dapui")
dapui.setup()
-- Listen to the events from dap and dapui
dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
end
