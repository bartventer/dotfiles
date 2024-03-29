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

-- Setting up clipboard configuration
vim.g.clipboard = {
  name = 'LinuxClipboard',
  copy = {
    ['+'] = 'xclip -selection clipboard -i',
    ['*'] = 'xclip -selection clipboard -i',
  },
  paste = {
    ['+'] = 'xclip -selection clipboard -o',
    ['*'] = 'xclip -selection clipboard -o',
  },
  cache_enabled = 1,
}
