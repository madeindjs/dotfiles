local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- theme
config.font_size = 11.0
-- config.window_background_opacity = 0.9
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- misc
config.check_for_updates = false

-- mac os
config.send_composed_key_when_left_alt_is_pressed = true -- allow MacOS keyboard special chars (see https://github.com/wez/wezterm/issues/3867)

-- keys

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "e",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
	{
		key = "o",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
}

return config
