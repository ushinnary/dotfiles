return {
	{
		"projekt0n/github-nvim-theme",
		config = function()
			-- check if linux system has dark mode enabled
			if
				vim.fn.system("gsettings get org.gnome.desktop.interface gtk-theme"):match("dark")
				or vim.fn.system("gsettings get org.gnome.desktop.interface color-scheme"):match("dark")
			then
				vim.cmd("colorscheme github_dark_default")
			else
				vim.cmd("colorscheme github_light")
			end
		end,
	},
}
