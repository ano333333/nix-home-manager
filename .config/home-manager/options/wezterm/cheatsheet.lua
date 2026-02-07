local wezterm = require("wezterm")

local M = {}

function M.ToggleCheatsheet(window)
  local new_tab, _, _ = window:mux_window():spawn_tab({
    args = { "nvim", wezterm.home_dir .. "/cheatsheet" },
  })
  new_tab:set_title("Cheatsheet")
end

return M
