-- Languages support
local remapper = require("ushinnary.remapper")
local nnoremap = remapper.nnoremap
local nvim_lsp = require("lspconfig")
local on_attach = function(callback)
	return function()
		-- Code related
		nnoremap("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
		nnoremap("gD", "<cmd>lua vim.lsp.buf.implementation()<CR>")
		nnoremap("gr", "<cmd>lua vim.lsp.buf.references()<CR>")
		nnoremap("ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
		nnoremap("K", "<cmd>lua vim.lsp.buf.hover()<CR>")
		nnoremap("<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
		if type(callback) == "function" then
			callback()
		end
	end
end

local servers = {
	bashls = { on_attach = on_attach() },
	svelte = { on_attach = on_attach() },
	cssls = { on_attach = on_attach() },
	dockerls = { on_attach = on_attach() },
	tsserver = { on_attach = on_attach() },
	--tailwindcss = {},
	taplo = { on_attach = on_attach() },
	omnisharp = { on_attach = on_attach() },
	jsonls = { on_attach = on_attach() },
	sumneko_lua = { on_attach = on_attach() },
	sqlls = { on_attach = on_attach() },
	volar = {
		on_attach = on_attach(),
		filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
	},
	rust_analyzer = {
		on_attach = on_attach(),
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
