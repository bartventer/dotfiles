local parser_set = {
	["lua"] = true,
	["vim"] = true,
	["typescript"] = true,
	["markdown"] = true,
	["vimdoc"] = true,
}

-- Optional parsers
local optional_parsers = {
	go = "go",
	-- Add more optional parsers here
}

for lang, parser in pairs(optional_parsers) do
	if vim.fn.executable(lang) == 1 then
		parser_set[parser] = true
	end
end

-- Convert set back to list
local parsers = {}
for parser in pairs(parser_set) do
	table.insert(parsers, parser)
end

require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all"
	ensure_installed = parsers,

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,
	auto_install = true,

	highlight = {
		enable = true,
	},
})
