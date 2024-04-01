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

-- Default formatters
local source_set = {
	-- Lua
	[formatting.stylua] = true,

	-- TypeScript
	-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#eslint_d-2
	-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#eslint_d
	-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#prettierd
	[diagnostics.eslint_d] = true,
	[code_actions.eslint_d] = true,
	[formatting.prettierd] = true,

	-- Python
	-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#black
	[formatting.black] = true,

	-- Github Actions (FYI requires `go`)
	-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#actionlint
	[diagnostics.actionlint] = true,
}

-- Language specific sources (key is the executable name to check)
local optional_sources = {
	["go"] = {
		-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#gomodifytags
		code_actions.gomodifytags,
		-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#impl
		code_actions.impl,
		-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#golangci_lint
		diagnostics.golangci_lint,
		-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#staticcheck
		diagnostics.staticcheck,
		-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#actionlint
		diagnostics.revive,
		-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#golines
		formatting.golines,
		-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#goimports_reviser
		formatting.goimports_reviser,
	},
	["bash"] = {
		-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#shellcheck
		diagnostics.shellcheck,
		code_actions.shellcheck,
		-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#beautysh
		formatting.beautysh,
	}
	-- Add more languages and their formatters here
}

for lang, sources in pairs(optional_sources) do
	if vim.fn.executable(lang) == 1 then
		for _, source in ipairs(sources) do
			source_set[source] = true
		end
	end
end

-- Convert set back to list
local sources = {}
for source in pairs(source_set) do
	table.insert(sources, source)
end

null_ls.setup({
	debug = false,
	sources = sources,
	on_attach = function(client, bufnr)
		enable_format_on_save(client, bufnr)
	end,
})
