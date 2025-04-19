local wezterm = require("wezterm")
local config = wezterm.config_builder()

----------------
-- UI Config
--------------

config.font = wezterm.font("IosevkaTerm Nerd Font")
config.color_scheme = "Catppuccin Frappe"
config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
config.enable_tab_bar = false
config.window_padding = {
  left = "1cell",
  right = "1cell",
  top = "0.5cell",
  bottom = "0cell"
}

-- Center window on startup
wezterm.on("gui-startup", function(cmd)
  local active_screen = wezterm.gui.screens().active
  -- Get your terminal size by running the command `printf '\e[16t'`
  -- TODO: this is hardcoded, is there any way to obtain the size?
  local cell_width = 12
  local cell_height = 30
  local screen_width = active_screen.width / cell_width
  local screen_height = active_screen.height / cell_height
  local spawn_width = math.floor(screen_width / 1.5)
  local spawn_height = math.floor(screen_height / 2)
  wezterm.mux.spawn_window(cmd or {
    width = spawn_width,
    height = spawn_height,
    position = {
      x = (active_screen.width - spawn_width * cell_width) / 2,
      y = (active_screen.height - spawn_height * cell_height) / 2  - 48
    }
  })
end)

----------------
-- Bindings
----------------

-- Define Alt-w as the leader key, so we can use <Alt-w><hjkl> to move
-- between panes similar to what we do in neovim (of course we could just use
-- <Alt-hjkl> but Alt-w is good as a mnemonic, as "w" stands for "window"):
config.leader = {
  key = "w",
  mods = "ALT",
  timeout_milliseconds = math.maxinteger
}

config.keys = {
  -- Split pane side by side with backslash
  {
    key = "\\",
    mods = "LEADER",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" })
  },

  -- Split pane top/bottom
  {
    key = "-",
    mods = "LEADER",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" })
  },

  -- Move between panes
  {
    key = "h",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Left")
  },
  {
    key = "j",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Down")
  },
  {
    key = "k",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Up")
  },
  {
    key = "l",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Right")
  },
}

----------------
-- Other
----------------

-- Never prompt to confirm closing
config.window_close_confirmation = "NeverPrompt"

-- Set up NixOS as the default domain
config.default_domain = "WSL:NixOS"

return config
