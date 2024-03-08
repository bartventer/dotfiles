require('dap-go').setup {
    -- Additional dap configurations can be added.
    -- dap_configurations accepts a list of tables where each entry
    -- represents a dap configuration. For more details do:
    -- :help dap-configuration
    dap_configurations = {
        {
            -- Must be "go" or it will be ignored by the plugin
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
        },
    },
    -- delve configurations
    delve = {
        -- the path to the executable dlv which will be used for debugging.
        -- by default, this is the "dlv" executable on your PATH.
        path = "dlv",
        -- time to wait for delve to initialize the debug session.
        -- default to 20 seconds
        initialize_timeout_sec = 20,
        -- a string that defines the port to start delve debugger.
        -- default to string "${port}" which instructs nvim-dap
        -- to start the process in a random available port
        port = "${port}",
        -- additional args to pass to dlv
        args = {},
        -- the build flags that are passed to delve.
        -- defaults to empty string, but can be used to provide flags
        -- such as "-tags=unit" to make sure the test suite is
        -- compiled during debugging, for example.
        -- passing build flags using args is ineffective, as those are
        -- ignored by delve in dap mode.
        build_flags = "",
    },
}

-- Debug a test function (https://github.com/leoluz/nvim-dap-go?tab=readme-ov-file#debugging-individual-tests)
vim.keymap.set('n', '<Leader>dt', function()
    dap_go.debug_test()
end)
-- Debug the last test (https://github.com/leoluz/nvim-dap-go?tab=readme-ov-file#debugging-individual-tests)
vim.keymap.set('n', '<Leader>dlt', function()
    dap_go.debug_last_test()
end)
