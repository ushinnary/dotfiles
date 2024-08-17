return {
	"rebelot/kanagawa.nvim",
	config = function()
		-- check if linux system has dark mode enabled
		if
			vim.fn.system("gsettings get org.gnome.desktop.interface gtk-theme"):match("dark")
			or vim.fn.system("gsettings get org.gnome.desktop.interface color-scheme"):match("dark")
		then
			vim.cmd("colorscheme kanagawa-dragon")
		else
			vim.cmd("colorscheme kanagawa-lotus")
		end
	end,
}
