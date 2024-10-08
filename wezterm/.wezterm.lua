local wezterm = require("wezterm")

local config = wezterm.config_builder()
local act = wezterm.action

-- theme
config.font_size = 11.0
-- config.window_background_opacity = 0.9
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- misc
config.check_for_updates = false
-- config.exit_behavior = "CloseOnCleanExit"

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

-- add actions

wezterm.on("augment-command-palette", function(window, pane)
	return {
		{
			brief = "Rename tab",
			icon = "md_rename_box",

			action = act.PromptInputLine({
				description = "Enter new name for tab",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		{
			brief = "[WT] Start writer-framework",
			icon = "cod_empty_window", -- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
			action = wezterm.action_callback(function(window, pane)
				local cwd = os.getenv("HOME") .. "/github/writer/writer-framework"
				local code_tab, code_tab_pane_1, code_win = window:mux_window():spawn_tab({ cwd = cwd })
				code_tab:set_title("nvim writer-framework")
				code_tab_pane_1:send_text("nvim .\n")

				local proc_tab, proc_tab_pane_1, proc_win = window:mux_window():spawn_tab({ cwd = cwd })
				proc_tab:set_title("writer procs")
				local proc_tab_pane_2 = proc_tab_pane_1:split({ direction = "Bottom", size = 0.75, cwd = cwd })
				local proc_tab_pane_3 = proc_tab_pane_2:split({ direction = "Right", size = 0.5, cwd = cwd })
				proc_tab_pane_1:send_text("writer-time.sh '?'")
				proc_tab_pane_2:send_text("poetry install && poetry run writer edit apps/hello --port 5000\n")
				proc_tab_pane_3:send_text("npm run dev\n")
			end),
		},
		{
			brief = "[CS] Start",
			icon = "cod_empty_window", -- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
			action = wezterm.action_callback(function(window, pane)
				local home = os.getenv("HOME")

				local fe_tab = window:mux_window():spawn_tab({ cwd = home .. "/github/app-frontends" })
				fe_tab:set_title("app-frontends")

				local be_tab = window:mux_window():spawn_tab({ cwd = home .. "/github/app-services" })
				be_tab:set_title("app-services")

				local note_tab, note_pane_1 =
					window:mux_window():spawn_tab({ cwd = home .. "/Documents/perso/@plaintext/vault" })
				note_tab:set_title("notes")
				note_pane_1:send_text("nvim .\n")
			end),
		},
	}
end)

return config
