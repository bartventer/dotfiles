vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- https://github.com/nvim-tree/nvim-tree.lua
require("nvim-tree").setup({
  view = {
    adaptive_size = true,
  },
})
