return {
	{
		"tokyonight.nvim",
		opts = {
			-- transparent = true,
			-- styles = {
			-- 	sidebars = "transparent",
			-- 	floats = "transparent",
			-- },
			style = "moon", -- The theme comes in three styles, `storm`, a darker variant `night` and `day`
			light_style = "day", -- The theme is used when the background is set to light
		},
		-- config = function()
		-- 	-- check if linux or WSL2 system has dark mode enabled
		-- 	if
		-- 		vim.fn.system("gsettings get org.gnome.desktop.interface gtk-theme"):match("dark")
		-- 		or vim.fn.system("gsettings get org.gnome.desktop.interface color-scheme"):match("dark")
		-- 		or (
		-- 			vim.fn.executable("powershell.exe")
		-- 			and vim.fn
		-- 				.system(
		-- 					'powershell.exe Get-ItemPropertyValue -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" -Name AppsUseLightTheme'
		-- 				)
		-- 				:match(0)
		-- 		)
		-- 	then
		-- 		vim.cmd("colorscheme tokyonight-night")
		-- 	else
		-- 		vim.cmd("colorscheme tokyonight-day")
		-- 	end
		-- end,
	},
}
