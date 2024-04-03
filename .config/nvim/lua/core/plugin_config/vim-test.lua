-- https://github.com/vim-test/vim-test

vim.g["test#strategy"] = "vimux"

-- Language specific test runners
vim.g["test#runners"] = {
  go = "delve",
  python = "pytest",
  javascript = "jest",
  typescript = "jest",
  rust = "cargo",
  lua = "busted",
  ruby = "rspec",
  elixir = "mix",
  default = "vimux",
}
