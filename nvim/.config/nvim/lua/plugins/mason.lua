return {
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"lua_ls",
				"ast_grep",
				"rust_analyzer",
				"csharp_ls",
				"dockerls",
				"sqlls",
				-- "sqlfluff",
				"taplo",
				"tailwindcss",
				"volar",
				"bashls",
				"jsonls",
				"cssls",
				"svelte",
				"angularls",
				"biome",
				-- "codelldb",
			},
		},
	},
}
