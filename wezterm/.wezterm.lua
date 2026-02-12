local wezterm = require("wezterm")

local config = wezterm.config_builder()
local act = wezterm.action

-- theme
config.font_size = 11.0
-- config.color_scheme = "Builtin Dark"
-- config.color_scheme = "3024 (base16)"
-- config.color_scheme = "Builtin Tango Dark"
-- config.color_scheme = "Derp (terminal.sexy)"
config.color_scheme = "Digerati (terminal.sexy)"

config.inactive_pane_hsb = {
	saturation = 0.7,
	brightness = 0.8,
}
-- config.window_background_opacity = 0.9
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

-- Custom tab title with active process indicator
local shells = { "zsh", "bash", "fish", "sh", "dash", "ksh", "tcsh", "csh", "nvim" }
local function is_shell(process_name)
	if not process_name then
		return true
	end
	local name = process_name:match("([^/]+)$") or process_name
	for _, shell in ipairs(shells) do
		if name == shell or name == "-" .. shell then
			return true
		end
	end
	return false
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local pane = tab.active_pane
	local title = tab.tab_title
	if not title or #title == 0 then
		title = pane.title
	end

	local process_name = pane.foreground_process_name
	local name = process_name and (process_name:match("([^/]+)$") or process_name) or ""
	local process_indicator = ""
	if name == "mpv" then
		process_indicator = "🎵"
	elseif not is_shell(process_name) then
		process_indicator = "⏳"
	end

	return process_indicator .. title
end)

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
				local proc_tab, proc_tab_pane_1, proc_win = window:mux_window():spawn_tab({ cwd = cwd })
				proc_tab:set_title("WF")
				local proc_tab_pane_2 = proc_tab_pane_1:split({ direction = "Bottom", size = 0.25, cwd = cwd })
				local proc_tab_pane_3 = proc_tab_pane_2:split({ direction = "Right", size = 0.5, cwd = cwd })
				proc_tab_pane_1:send_text("poetry run nvim .\n")
				proc_tab_pane_2:send_text("poetry run writer edit playground/text-demo --port 5000\n")
				proc_tab_pane_3:send_text("npm run dev\n")
				proc_tab:activate()
			end),
		},
		{
			brief = "[WT] Start writer-framework@upstream",
			icon = "cod_empty_window", -- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
			action = wezterm.action_callback(function(window, pane)
				local cwd = os.getenv("HOME") .. "/github/writer/writer-framework@upstream"
				local proc_tab, proc_tab_pane_1, proc_win = window:mux_window():spawn_tab({ cwd = cwd })
				proc_tab:set_title("WF@up")
				local proc_tab_pane_2 = proc_tab_pane_1:split({ direction = "Bottom", size = 0.25, cwd = cwd })
				local proc_tab_pane_3 = proc_tab_pane_2:split({ direction = "Right", size = 0.5, cwd = cwd })
				proc_tab_pane_1:send_text("poetry run nvim .\n")
				proc_tab_pane_2:send_text("poetry run writer edit playground/text-demo --port 5000\n")
				proc_tab_pane_3:send_text("npm run dev\n")
				proc_tab:activate()
			end),
		},
		{
			brief = "[iSignif] Start isignif + chat",
			icon = "cod_empty_window", -- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
			action = wezterm.action_callback(function(window)
				-- @param relative_path string: The path relative to the home directory.
				-- @param bash_script string: The command to execute in the rails_pane_2.
				local function setup_window(title, relative_path, bash_script)
					local cwd = os.getenv("HOME") .. relative_path
					local tab, pane_1 = window:mux_window():spawn_tab({ cwd = cwd })
					tab:set_title(title)
					pane_1:send_text("nvim .\n")
					local pane_2 = pane_1:split({ direction = "Bottom", size = 0.25, cwd = cwd })
					pane_2:send_text(bash_script .. "\n")
					return tab
				end

				local rails_tab = setup_window("isignif/rails", "/github/isignif/website", "rails s")
				setup_window("isignif/ai", "/github/isignif/pdf-ai", "npm run dev")
				rails_tab:activate()
			end),
		},
	}
end)

return config
