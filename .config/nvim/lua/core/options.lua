vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.backspace = "2"
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true

-- use spaces for tabs and whatnot
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.cmd([[ set noswapfile ]])

--Line numbers
vim.wo.number = true

-- Python3 provider
local nvim_venv = os.getenv("NVIM_VENV")
if nvim_venv then
  vim.g.python3_host_prog = nvim_venv .. "/bin/python"
else
  print("Warning: NVIM_VENV is not set")
end

-- OS-specific clipboard configuration
-- Check the operating system and set the copy and paste commands
local OS = io.popen('uname -s'):read('*l')
local COPY_CMD = ''
local PASTE_CMD = ''

if OS == 'Linux' then
  COPY_CMD = 'xclip -selection clipboard -i'
  PASTE_CMD = 'xclip -selection clipboard -o'
elseif OS == 'Darwin' then
  COPY_CMD = 'pbcopy'
  PASTE_CMD = 'pbpaste'
else
  print('Unsupported operating system for clipboard configuration.')
  return
end

-- Check if copy and paste commands are available
if os.execute('command -v ' .. COPY_CMD) == 0 and os.execute('command -v ' .. PASTE_CMD) == 0 then
  vim.g.clipboard = {
    name = OS .. 'Clipboard',
    copy = {
      ['+'] = COPY_CMD,
      ['*'] = COPY_CMD,
    },
    paste = {
      ['+'] = PASTE_CMD,
      ['*'] = PASTE_CMD,
    },
    cache_enabled = 1
  }
else
  print('Copy or paste command not found. Clipboard configuration not set.')
end
