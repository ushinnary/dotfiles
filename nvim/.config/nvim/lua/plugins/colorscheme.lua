return {
	{
		"rebelot/kanagawa.nvim",
		config = function()
			-- check if linux or WSL2 system has dark mode enabled
			if
				vim.fn.system("gsettings get org.gnome.desktop.interface gtk-theme"):match("dark")
				or vim.fn.system("gsettings get org.gnome.desktop.interface color-scheme"):match("dark")
				or (
					vim.fn.executable("powershell.exe")
					and vim.fn
						.system(
							'powershell.exe Get-ItemPropertyValue -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" -Name AppsUseLightTheme'
						)
						:match(0)
				)
			then
				vim.cmd("colorscheme kanagawa-wave")
			else
				vim.cmd("colorscheme kanagawa-lotus")
			end
		end,
	},
}
