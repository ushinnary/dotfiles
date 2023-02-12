return {
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"sumneko_lua",
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
			},
		},
	},
}
