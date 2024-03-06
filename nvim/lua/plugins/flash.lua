return {
	{
		"folke/flash.nvim",
		keys = {
			{ "s", false },
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
		},
	},
}
