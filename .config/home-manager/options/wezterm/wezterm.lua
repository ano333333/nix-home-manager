local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()
config.automatically_reload_config = true

config.color_scheme = "Calamity"
config.disable_default_key_bindings = true
config.enable_tab_bar = false

config.font_size = 10.0
config.font = wezterm.font("HackGen Console NF")
config.warn_about_missing_glyphs = false

-- disable ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
-- 日本語IMEを使う
config.use_ime = true

-- 背景ブラーが可能なmacのみ、背景透過とブラーを設定
if wezterm.target_triple == "aarch64-apple-darwin" then
  config.window_background_opacity = 0.85
  config.macos_window_background_blur = 20
end

config.initial_cols = 80
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- タブのタイトル更新時のイベントを拾い、アクティブなタブの背景色を変更する
wezterm.on(
  "format-tab-title",
  function(tab, tabs, panes, config, hover, max_width)
    local background = "#5c6d74"
    local foreground = "#ffffff"

    if tab.is_active then
      background = "#ae8b2d"
      foreground = "#ffffff"
    end

    return {
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = tab.active_pane.title },
    }
  end
)

-- nekotyan
local chunk, err = loadfile(wezterm.config_dir .. "/nekotyan/nekotyan.lua")
if chunk ~= nil then
  local res, chunk_err = chunk()
  if chunk_err ~= nil then
    wezterm.log_error(chunk_err)
  end
else
  wezterm.log_error(err)
end

config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables

return config
