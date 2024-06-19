return {
	"nvim-neo-tree/neo-tree.nvim",
	opts = {
		sources = { "filesystem" },
		filesystem = {
			filtered_items = {
				--visible = true,
				hide_dotfiles = false,
				hide_gitignored = true,
				hide_by_name = {
					".github",
					".gitignore",
					"package-lock.json",
				},
				never_show = { ".git", "node_modules" },
			},
		},
		window = {
			position = "right",
		},
	},
}
