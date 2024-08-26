local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = "AdventureTime"
config.font = wezterm.font("JetBrains Mono")

-- allow MacOS keyboard special chars (see https://github.com/wez/wezterm/issues/3866)
config.send_composed_key_when_left_alt_is_pressed = true

-- and finally, return the configuration to wezterm
return config
