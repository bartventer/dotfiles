require("mason").setup()
require("mason-lspconfig").setup()

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

require("lspsaga").setup({
	code_action_icon = "💡",
	symbol_in_winbar = {
		in_custom = false,
		enable = true,
		separator = " ",
		show_file = true,
		file_formatter = "",
	},
})

local opts = { silent = true }

-- LSP finder - Find the symbol's definition
-- If there is no definition, it will instead be hidden
-- When you use an action in finder like "open vsplit",
-- you can use <C-t> to jump back
vim.keymap.set("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", opts)

-- Code action
vim.keymap.set({ "n", "v" }, "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)

-- Rename all occurrences of the hovered word for the entire file
vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)

-- Rename all occurrences of the hovered word for the selected files
vim.keymap.set("n", "gr", "<cmd>Lspsaga rename ++project<CR>", opts)

-- Peek definition
-- You can edit the file containing the definition in the floating window
-- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
-- It also supports tagstack
-- Use <C-t> to jump back
vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)

-- Go to definition
-- vim.keymap.set("n","gd", "<cmd>Lspsaga goto_definition<CR>", {silent = true})

-- Peek type definition
-- You can edit the file containing the type definition in the floating window
-- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
-- It also supports tagstack
-- Use <C-t> to jump back
vim.keymap.set("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>", opts)

-- Go to type definition
-- vim.keymap.set("n","gt", "<cmd>Lspsaga goto_type_definition<CR>", {silent = true})

-- Show line diagnostics
-- You can pass argument ++unfocus to
-- unfocus the show_line_diagnostics floating window
vim.keymap.set("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)

-- Show buffer diagnostics
vim.keymap.set("n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>", opts)

-- Show workspace diagnostics
vim.keymap.set("n", "<leader>sw", "<cmd>Lspsaga show_workspace_diagnostics<CR>", opts)

-- Show cursor diagnostics
vim.keymap.set("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts)

-- Diagnostic jump
-- You can use <C-o> to jump back to your previous location
vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)

-- Diagnostic jump with filters such as only jumping to an error
vim.keymap.set("n", "[E", function()
	require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "]E", function()
	require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end)

-- Toggle outline
vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", opts)

-- Hover Doc
-- If there is no hover doc,
-- there will be a notification stating that
-- there is no information available.
-- To disable it just use ":Lspsaga hover_doc ++quiet"
-- Pressing the key twice will enter the hover window
vim.keymap.set("n", "K", "<Cmd>Lspsaga hover_doc<cr>", opts)

-- Floating terminal
vim.keymap.set({ "n", "t" }, "<A-d>", "<cmd>Lspsaga term_toggle<CR>", opts)

-- null-ls formatting
local null_formatting = function(bufnr)
	vim.lsp.buf.format({
		bufnr = bufnr,
		filter = function(client)
			return client.name == "null-ls"
		end,
	})
end

-- Enable formatting on save :
require("lspconfig").lua_ls.setup({
	capabilities = capabilities,
	on_attach = function(_, bufnr)
		vim.keymap.set("n", "<leader>lf", function()
			null_formatting(bufnr)
		end)
	end,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
})

-- Ruby language server
-- require("lspconfig").solargraph.setup({
-- 	capabilities = capabilities,
-- })

-- TypeScript language server
require("lspconfig").tsserver.setup({
	capabilities = capabilities,
})

-- Go language server
require("lspconfig").gopls.setup({
	capabilities = capabilities,
})

-- Python language server
require("lspconfig").pyright.setup({
	capabilities = capabilities,
})
