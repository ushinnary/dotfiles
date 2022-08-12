require('telescope').setup{
	defaults = {
		mappings = {
			i = {
				["<C-h>"] = "which_key"
			}
		}
	}
}
require('lualine').setup()

