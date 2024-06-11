return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = { "hrsh7th/cmp-emoji" },
		---@param opts cmp.ConfigSchema
		opts = function(_, opts)
			local cmp = require("cmp")
			opts.mapping = vim.tbl_extend("force", opts.mapping, {
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.confirm({
							begavior = cmp.ConfirmBehavior.Insert,
							select = true,
						})
					else
						fallback()
					end
				end, { "i", "s" }),
			})
			-- override nvim-cmp and add cmp-emoji
			table.insert(opts.sources, { name = "emoji" })
		end,
	},
}
