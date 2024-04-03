-- whichkey.lua

local which_key = require("which-key")

local setup = {
	plugins = {
		marks = true, -- shows a list of your marks on ' and `
		registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
		-- the presets plugin, adds help for a bunch of default keybindings in Neovim
		-- No actual key bindings are created
		spelling = {
			enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
			suggestions = 20, -- how many suggestions should be shown in the list?
		},
		presets = {
			operators = true, -- adds help for operators like d, y, ...
			motions = true, -- adds help for motions
			text_objects = true, -- help for text objects triggered after entering an operator
			windows = true, -- default bindings on <c-w>
			nav = true, -- misc bindings to work with windows
			z = true,   -- bindings for folds, spelling and others prefixed with z
			g = true,   -- bindings for prefixed with g
		},
	},
	-- add operators that will trigger motion and text object completion
	-- to enable all native operators, set the preset / operators plugin above
	operators = { gc = "Comments" },
	key_labels = {
		-- override the label used to display some keys. It doesn't effect WK in any other way.
		-- For example:
		-- ["<space>"] = "SPC",
		-- ["<cr>"] = "RET",
		-- ["<tab>"] = "TAB",
	},
	motions = {
		count = true,
	},
	icons = {
		breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
		separator = "➜", -- symbol used between a key and it's label
		group = "+", -- symbol prepended to a group
	},
	popup_mappings = {
		scroll_down = "<c-d>", -- binding to scroll down inside the popup
		scroll_up = "<c-u>", -- binding to scroll up inside the popup
	},
	window = {
		border = "none",    -- none, single, double, shadow
		position = "bottom", -- bottom, top
		margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]. When between 0 and 1, will be treated as a percentage of the screen size.
		padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
		winblend = 0,       -- value between 0-100 0 for fully opaque and 100 for fully transparent
		zindex = 1000,      -- positive value to position WhichKey above other floating windows.
	},
	layout = {
		height = { min = 4, max = 25 },                                            -- min and max height of the columns
		width = { min = 20, max = 50 },                                            -- min and max width of the columns
		spacing = 3,                                                               -- spacing between columns
		align = "left",                                                            -- align columns left, center or right
	},
	ignore_missing = false,                                                        -- enable this to hide mappings for which you didn't specify a label
	hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " }, -- hide mapping boilerplate
	show_help = true,                                                              -- show a help message in the command line for using WhichKey
	show_keys = true,                                                              -- show the currently pressed key and its label as a message in the command line
	triggers = "auto",                                                             -- automatically setup triggers
	-- triggers = {"<leader>"} -- or specifiy a list manually
	-- list of triggers, where WhichKey should not wait for timeoutlen and show immediately
	triggers_nowait = {
		-- marks
		"`",
		"'",
		"g`",
		"g'",
		-- registers
		'"',
		"<c-r>",
		-- spelling
		"z=",
	},
	triggers_blacklist = {
		-- list of mode / prefixes that should never be hooked by WhichKey
		-- this is mostly relevant for keymaps that start with a native binding
		i = { "j", "k" },
		v = { "j", "k" },
	},
	-- disable the WhichKey popup for certain buf types and file types.
	-- Disabled by default for Telescope
	disable = {
		buftypes = {},
		filetypes = {},
	},
}
local opts = {
	mode = "n",  -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}

local mappings = {
	-- General
	["e"] = { "<cmd>NvimTreeToggle<cr>", "Explorer" }, -- File Explorer
	["k"] = { "<cmd>bdelete<CR>", "Kill Buffer" },  -- Close current file
	["D"] = { "<cmd>Dashboard<CR>", "Dashboard" },  -- Dashboard
	["I"] = { "<cmd>LspInfo<cr>", "Info" },         -- LSP Info
	["L"] = { "<cmd>luafile %<CR>", "Reload Lua" }, -- Reload Lua config
	["m"] = { "<cmd>Mason<cr>", "Mason" },          -- LSP Manager
	["p"] = { "<cmd>Lazy<CR>", "Plugin Manager" },  -- Invoking plugin manager
	["q"] = { "<cmd>wqall!<CR>", "Quit" },          -- Quit Neovim after saving the file
	["w"] = { "<cmd>w!<CR>", "Save" },              -- Save current file,
	["y"] = { "<cmd>:%y+<CR>", "Yank File" },       -- Yank entire file to clipboard

	-- Language Support
	l = {
		name = "LSP",
		f = { "<cmd>lua vim.lsp.buf.format{async=true}<cr>", "Reformat Code" },
		s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
		S = {
			"<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
			"Workspace Symbols",
		},
	},

	-- Telescope
	["h"] = { "<cmd>Telescope help_tags<cr>", "Find Help" },
	["M"] = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
	["R"] = { "<cmd>Telescope registers<cr>", "Registers" },
	["K"] = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
	["C"] = { "<cmd>Telescope commands<cr>", "Commands" },
	f = {
		name = "File Search",
		f = { "<cmd>lua require('telescope.builtin').find_files()<cr>", "Find files" },
		t = { "<cmd>Telescope live_grep <cr>", "Find Text Pattern" },
		r = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
	},
	t = {
		name = "Advanced Search",
		c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
		h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
		m = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
		r = { "<cmd>Telescope registers<cr>", "Registers" },
		k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
		C = { "<cmd>Telescope commands<cr>", "Commands" },
	},

	-- DAP Mappings
	d = {
		name = "DAP",
		c = { "<cmd>lua require('dap').continue()<cr>", "Continue" },
		o = { "<cmd>lua require('dap').step_over()<cr>", "Step Over" },
		i = { "<cmd>lua require('dap').step_into()<cr>", "Step Into" },
		u = { "<cmd>lua require('dap').step_out()<cr>", "Step Out" },
		b = { "<cmd>lua require('dap').toggle_breakpoint()<cr>", "Toggle Breakpoint" },
		B = { "<cmd>lua require('dap').set_breakpoint()<cr>", "Set Breakpoint" },
		p = { "<cmd>lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>", "Set Log Point" },
		r = { "<cmd>lua require('dap').repl.open()<cr>", "Open REPL" },
		l = { "<cmd>lua require('dap').run_last()<cr>", "Run Last" },
		h = { "<cmd>lua require('dap.ui.widgets').hover()<cr>", "Hover" },
		P = { "<cmd>lua require('dap.ui.widgets').preview()<cr>", "Preview" },
		f = { "<cmd>lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').frames)<cr>", "Frames" },
		s = { "<cmd>lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').scopes)<cr>", "Scopes" },
		t = { "<cmd>lua require('dap').run({type = 'go', name = 'Debug test file', request = 'launch', mode = 'test', program = '${file}'})<cr>", "Debug Test File" },
		T = { "<cmd>lua require('dap').run({type = 'go', name = 'Debug test package', request = 'launch', mode = 'test', program = '${fileDirname}'})<cr>", "Debug Test Package" },
	},

	-- LSP Saga Mappings
	s = {
		name = "LSP Saga",
		h = { "<cmd>Lspsaga lsp_finder<CR>", "LSP Finder" },
		a = { "<cmd>Lspsaga code_action<CR>", "Code Action" },
		R = { "<cmd>Lspsaga rename<CR>", "Rename" },
		r = { "<cmd>Lspsaga rename ++project<CR>", "Rename Project-wide" },
		d = { "<cmd>Lspsaga peek_definition<CR>", "Peek Definition" },
		t = { "<cmd>Lspsaga peek_type_definition<CR>", "Peek Type Definition" },
		l = { "<cmd>Lspsaga show_line_diagnostics<CR>", "Show Line Diagnostics" },
		b = { "<cmd>Lspsaga show_buf_diagnostics<CR>", "Show Buffer Diagnostics" },
		w = { "<cmd>Lspsaga show_workspace_diagnostics<CR>", "Show Workspace Diagnostics" },
		c = { "<cmd>Lspsaga show_cursor_diagnostics<CR>", "Show Cursor Diagnostics" },
		e = { "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Diagnostic Jump Prev" },
		E = { "<cmd>Lspsaga diagnostic_jump_next<CR>", "Diagnostic Jump Next" },
		o = { "<cmd>Lspsaga outline<CR>", "Outline" },
		K = { "<Cmd>Lspsaga hover_doc<cr>", "Hover Doc" },
		D = { "<cmd>Lspsaga term_toggle<CR>", "Toggle Terminal" },
	},

}

which_key.setup(setup)
which_key.register(mappings, opts)

which_key.setup(setup)
which_key.register(mappings, opts)
