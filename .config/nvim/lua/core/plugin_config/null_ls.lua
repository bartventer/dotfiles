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

-- Default sources
local formatter_set = {
	-- Lua
	[formatting.stylua] = true,
	-- TypeScript
	[diagnostics.eslint_d] = true,
	[code_actions.eslint_d] = true,
	[formatting.prettierd] = true,
	-- Python
	[formatting.black] = true,
}

-- Language specific formatters
local optional_formatters = {
	go = { "goimports_reviser", "golines" },
	-- Add more languages and their formatters here
}

for lang, formatters in pairs(optional_formatters) do
	if vim.fn.executable(lang) == 1 then
		for _, formatter in ipairs(formatters) do
			local formatter_name = formatter:gsub("-", "_")
			if formatting[formatter_name] then
				formatter_set[formatting[formatter_name]] = true
			else
				vim.api.nvim_err_writeln("Invalid formatter: " .. formatter)
			end
		end
	end
end

-- Convert set back to list
local formatters = {}
for formatter in pairs(formatter_set) do
	table.insert(formatters, formatter)
end

null_ls.setup({
	debug = false,
	sources = formatters,
	on_attach = function(client, bufnr)
		enable_format_on_save(client, bufnr)
	end,
})
