return {

	{ -- plugin spec for catppuccin
		"catppuccin/nvim",
		-- this belongs to no plugin spec and is ignored
		lazy = false,
		name = "catppuccin",
		opts = {
			flavour = "auto", -- latte, frappe, macchiato, mocha
			background = { -- :h background
				light = "latte",
				dark = "mocha",
			},
			transparent_background = true,
		},
	},

	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
		},
	},
}
