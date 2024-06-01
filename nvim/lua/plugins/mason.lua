return {
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"lua_ls",
				"ast_grep",
				"rust_analyzer",
				"omnisharp",
				"dockerls",
				"sqlls",
				"taplo",
				"tailwindcss",
				"volar",
				"bashls",
				"jsonls",
				"cssls",
				"svelte",
				"angularls",
				"biome",
			},
		},
	},
}
