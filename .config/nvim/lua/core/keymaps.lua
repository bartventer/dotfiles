-- Navigate vim panes better
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")

-- Move current line / block with Alt j/k ala vscode.
-- Visual Mode
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")
-- Normal mode
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")

-- Insert a new line below without entering insert mode.
vim.keymap.set("n", "<leader>o", "o<Esc>")

-- DAP mappings
vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
vim.keymap.set('n', '<Leader>lp',
    function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function() require('dap.ui.widgets').hover() end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function() require('dap.ui.widgets').preview() end)
vim.keymap.set('n', '<Leader>df',
    function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.frames)
    end)
vim.keymap.set('n', '<Leader>ds',
    function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.scopes)
    end)
-- Debug a test function (https://github.com/leoluz/nvim-dap-go?tab=readme-ov-file#debugging-individual-tests)
vim.keymap.set('n', '<Leader>dt', function()
    require('dap-go').debug_test()
end)
-- Debug the last test (https://github.com/leoluz/nvim-dap-go?tab=readme-ov-file#debugging-individual-tests)
vim.keymap.set('n', '<Leader>dlt', function()
    require('dap-go').debug_last_test()
end)
-- Debug a test file
vim.keymap.set('n', '<Leader>dtf', function()
    require 'dap'.run({
        type = 'go',
        name = 'Debug test file',
        request = 'launch',
        mode = 'test',
        program = '${file}',
    })
end)
-- Debug a test package
vim.keymap.set('n', '<Leader>dtp', function()
    require 'dap'.run({
        type = 'go',
        name = 'Debug test package',
        request = 'launch',
        mode = 'test',
        program = '${fileDirname}',
    })
end)



-- nvim-dap-ui mappings
vim.keymap.set('n', '<leader>do', function() require('dapui').open() end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ds', function() require('dapui').toggle_sidebar() end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>dq', function() require('dapui').close() end, { noremap = true, silent = true })
