local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	-- theme
	"folke/tokyonight.nvim",
	"ellisonleao/gruvbox.nvim",
	{
		"dracula/vim",
		lazy = false,
	},
	"nvim-tree/nvim-tree.lua",      -- file tree
	"nvim-tree/nvim-web-devicons",  -- file tree icons
	"nvim-lualine/lualine.nvim",    -- status line
	"nvim-treesitter/nvim-treesitter", -- syntax highlighting
	"bluz71/vim-nightfly-colors",   -- colorscheme
	"vim-test/vim-test",            -- test runner
	"lewis6991/gitsigns.nvim",      -- git signs
	-- tmux
	"preservim/vimux",
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		config = function()
			require("core.plugin_config.vim-tmux-navigator")
		end,
	},
	"tpope/vim-fugitive",  -- git
	"windwp/nvim-autopairs", -- auto pairs
	"windwp/nvim-ts-autotag", -- auto close tag
	"numToStr/Comment.nvim", -- comments gcc and gc
	{
		-- dashboard
		"glepnir/dashboard-nvim",
		event = "VimEnter",
		dependencies = { { "nvim-tree/nvim-web-devicons" } },
	},
	"jose-elias-alvarez/null-ls.nvim", -- null-ls
	-- completion
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"rafamadriz/friendly-snippets",
	"github/copilot.vim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",
	"williamboman/mason.nvim",
	"glepnir/lspsaga.nvim",
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { { "nvim-lua/plenary.nvim" } },
	},
	-- Which-key
	{
		"folke/which-key.nvim",
		lazy = true,
	},
	-- Debugging
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" }
	},
	"theHamsta/nvim-dap-virtual-text",
}

-- Optional plugins (map of command to check to list of plugins to add)
local optional_plugins = {
	["go"] = { "leoluz/nvim-dap-go" },
}

for cmd, plugin in pairs(optional_plugins) do
	if vim.fn.executable(cmd) == 1 then
		table.insert(plugins, plugin)
	end
end

local opts = {}

require("lazy").setup(plugins, opts)
