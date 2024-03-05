local dotfile = os.getenv("MYVIMRC")

require("dashboard").setup({
	theme = "hyper",
	config = {
		week_header = {
			enable = true,
		},
		shortcut = {
			-- Update plugins.
			{ desc = " Update", group = "@property", action = "Lazy update", key = "u" },
			-- Find file.
			{
				icon = " ",
				icon_hl = "@variable",
				desc = "Files",
				group = "Label",
				action = "Telescope find_files",
				key = "f",
			},
			-- Create a new file with CMD.
			{
				desc = " New File",
				group = "DiagnosticHint",
				-- Create a new file and set the working directory to the current directory.
				action = "edit + | lcd %:p:h",
				key = "n",
			},
			-- Recent files.
			{
				desc = " Recents",
				group = "DiagnosticHint",
				action = "Telescope oldfiles",
				key = "r",
			},
			-- Find text.
			{
				desc = " Find Text",
				group = "DiagnosticHint",
				action = "Telescope live_grep",
				key = "t",
			},
			-- Edit the dotfile.
			{
				desc = " Config",
				group = "Number",
				-- Edit the dotfile and set the working directory to the dotfile directory, and with NvimTree open.
				action = "edit " .. dotfile .. " | lcd " .. vim.fn.fnamemodify(dotfile, ":h") .. " | NvimTreeToggle",
				key = "d",
			},
			-- Quit dashboard.
			{
				desc = " Quit",
				group = "DiagnosticHint",
				action = "quit",
				key = "q",
			},
		},
	},
})
