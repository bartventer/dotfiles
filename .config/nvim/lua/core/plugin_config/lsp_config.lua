-- https://github.com/hrsh7th/cmp-nvim-lsp
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- https://github.com/nvimdev/lspsaga.nvim
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

-- Integration with null-ls
local null_formatting = function(bufnr)
	vim.lsp.buf.format({
		bufnr = bufnr,
		filter = function(client)
			return client.name == "null-ls"
		end,
	})
end

-- ============================================================================
-- LSP LANGUAGE SERVERS
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations
-- ============================================================================

-- Lua language server
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
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

-- TypeScript language server
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver
require("lspconfig").tsserver.setup({
	capabilities = capabilities,
})

-- Python language server
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#pyright
require("lspconfig").pyright.setup({
	capabilities = capabilities,
})

-- JSON language server
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls
require("lspconfig").jsonls.setup({
	capabilities = capabilities,
})

-- YAML language server
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#yamlls
require 'lspconfig'.yamlls.setup {}

-- Optional servers (key is the executable name to check)
local optional_servers = {
	["go"] = {
		-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
		name = "gopls",
		config = {
			capabilities = capabilities,
		}
	},
	["bash"] = {
		-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#bashls
		name = "bashls",
		config = {
			capabilities = capabilities,
		}
	},
	["docker"] = {
		-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#dockerls
		name = "dockerls",
		config = {
			capabilities = capabilities,
		}
	},
	["docker-compose"] = {
		-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#docker_compose_language_service
		name = "docker_compose_language_service",
		config = {
			capabilities = capabilities,
			on_attach = function(_, _)
				vim.cmd [[
                    autocmd BufRead,BufNewFile docker-compose.{yaml,yml} set filetype=yaml.docker-compose
                ]]
			end,
		}
	},
	["terraform"] = {
		-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#terraformls
		name = "terraformls",
		config = {
			capabilities = capabilities,
		},
	},
}

for lang, server in pairs(optional_servers) do
	if vim.fn.executable(lang) == 1 then
		require("lspconfig")[server.name].setup(server.config)
	end
end
