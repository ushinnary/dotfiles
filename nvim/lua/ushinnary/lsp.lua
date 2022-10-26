-- Languages support
local nvim_lsp = require("lspconfig")

local servers = {
	tsserver = {},
	cssls = {},
	dockerls = {},
	tailwindcss = {},
	omnisharp = {},
	bashls = {},
	taplo = {},
	jsonls = {},
	sumneko_lua = {},
	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				imports = {
					granularity = {
						group = "module",
					},
					prefix = "self",
				},
				cargo = {
					buildScripts = {
						enable = true,
					},
				},
				procMacro = {
					enable = true,
				},
				checkOnSave = {
					command = "clippy",
				},
			},
		},
	},
}

for name, config in pairs(servers) do
	nvim_lsp[name].setup(config)
end
