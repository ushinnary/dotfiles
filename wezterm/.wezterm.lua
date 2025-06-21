-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 30

local function set_scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		config.window_background_opacity = 0.6
		config.kde_window_background_blur = true
		config.color_scheme = "Catppuccin Mocha"
	else
		config.window_background_opacity = 1
		config.kde_window_background_blur = false
		config.color_scheme = "Catppuccin Latte"
	end
end

-- or, changing the font size and color scheme.
config.font_size = 14
set_scheme_for_appearance(wezterm.gui.get_appearance())

config.font = wezterm.font_with_fallback({
	"Sono",
	"Quicksand",
	"Adwaita Mono",
})

-- Finally, return the configuration to wezterm:
return config
