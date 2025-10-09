return {

	{ -- plugin spec for catppuccin
		"rebelot/kanagawa.nvim",
		-- this belongs to no plugin spec and is ignored
		lazy = false,
		name = "kanagawa",
		opts = {
			theme = "wave", -- Load "wave" theme
			background = { -- map the value of 'background' option to a theme
				dark = "wave", -- try "dragon" !
				light = "lotus",
			},
		},
	},

	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "kanagawa",
		},
	},
}
