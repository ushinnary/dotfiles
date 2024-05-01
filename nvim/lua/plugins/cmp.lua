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

			opts.sorting.comparators = {
				cmp.config.compare.offset,
				cmp.config.compare.exact,
				-- compare.scopes,
				cmp.config.compare.score,
				cmp.config.compare.recently_used,
				cmp.config.compare.locality,
				cmp.config.compare.kind,
				-- compare.sort_text,
				cmp.config.compare.length,
				cmp.config.compare.order,
			}
		end,
	},
}
