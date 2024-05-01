return {
	"catppuccin/nvim",
	-- Add in any other configuration;
	--   event = foo,
	--   config = bar
	--   end,
	config = function()
		-- check if linux system has dark mode enabled
		if
			vim.fn.system("gsettings get org.gnome.desktop.interface gtk-theme"):match("dark")
			or vim.fn.system("gsettings get org.gnome.desktop.interface color-scheme"):match("dark")
		then
			vim.cmd("colorscheme catppuccin-mocha")
		else
			vim.cmd("colorscheme tokyonight-day")
		end
	end,
}
