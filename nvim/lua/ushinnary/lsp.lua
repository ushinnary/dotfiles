-- Languages support
local nvim_lsp = require("lspconfig")

local servers = {
	bashls = {},
	svelte = {},
	cssls = {},
	dockerls = {},
	tsserver = {},
	--tailwindcss = {},
	taplo = {},
	omnisharp = {},
	jsonls = {},
	sumneko_lua = {},
	sqlls = {},
	volar = {
		filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
	},
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
