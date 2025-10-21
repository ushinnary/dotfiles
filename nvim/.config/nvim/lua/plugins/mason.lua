return {
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"lua_ls",
				"ast_grep",
				"rust_analyzer",
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
