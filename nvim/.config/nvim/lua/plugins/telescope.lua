return {
	{
		"nvim-telescope/telescope.nvim",
		opts = {
			defaults = {
				file_ignore_patterns = { "node_modules", ".git" },
				layout_strategy = "vertical",
				layout_config = {
					vertical = {
						preview_cutoff = 0,
					},
				},
			},
		},
	},
}
