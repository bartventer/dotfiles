local null_ls = require("null-ls")

-- Enable formatting on save : https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local enable_format_on_save = function(client, bufnr)
	if client.supports_method("textDocument/formatting") then
		-- clear autocmds for this buffer
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		-- set autocmds for this buffer
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end,
		})
		-- set keymap for formatting
		vim.keymap.set("n", "<leader>lf", function()
			vim.lsp.buf.format({ bufnr = bufnr })
		end)
	end
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/code_actions
local code_actions = null_ls.builtins.code_actions
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
	debug = false,
	sources = {
		-- lua
		formatting.stylua,
		-- typescript
		diagnostics.eslint_d,
		code_actions.eslint_d,
		formatting.prettierd,
		-- python
		formatting.black,
		-- go
		formatting.goimports_reviser,
	},
	on_attach = function(client, bufnr)
		enable_format_on_save(client, bufnr)
	end,
})
