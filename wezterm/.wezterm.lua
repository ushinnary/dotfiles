-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 30

config.font_size = 14
config.color_scheme = "Catppuccin Mocha"

config.font = wezterm.font_with_fallback({
	"Sono",
	"Quicksand",
	"Adwaita Mono",
})

-- Finally, return the configuration to wezterm:
return config
