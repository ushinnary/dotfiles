return {
	"nyoom-engineering/oxocarbon.nvim",
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
			vim.opt.background = "dark" -- set this to dark or light
		else
			vim.opt.background = "light" -- set this to dark or light
		end
		vim.cmd("colorscheme oxocarbon")
	end,
}
