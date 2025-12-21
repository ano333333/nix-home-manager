local wezterm = require 'wezterm'

local config = wezterm.config_builder()
config.automatically_reload_config = true

config.color_scheme = 'Calamity'

config.font_size = 12.0
-- 日本語IMEを使う
config.use_ime = true

-- 背景ブラーが可能なmacのみ、背景透過とブラーを設定
if wezterm.target_triple == 'aarch64-apple-darwin' then
    config.window_background_opacity = 0.85
    config.macos_window_background_blur = 20
end

-- Linux + Waylandでウィンドウの移動やリサイズが出来ない問題の対応
-- see: https://github.com/wezterm/wezterm/pull/6923#issuecomment-2848766442
if wezterm.target_triple == 'x86_64-unknown-linux-gnu' then
    config.window_decorations = 'RESIZE'
end

-- タブのタイトル更新時のイベントを拾い、アクティブなタブの背景色を変更する
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local background = '#5c6d74'
    local foreground = '#ffffff'

    if tab.is_active then
        background = '#ae8b2d'
        foreground = '#ffffff'
    end

    return {
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = tab.active_pane.title },
    }
end)

-- ウィンドウのフォーカスが変わった時に背景を変更する
wezterm.on('window-focus-changed', function(window, pane)
    local background_layer = {
        source = {
            Color = 'black'
        },
        width = '100%',
        height = '100%',
    }
    local image_layer = {
        source = {
            File = '/home/ano3/.config/wezterm/image.png'
        },
        opacity = 0.3,
        vertical_align = 'Bottom',
        horizontal_align = 'Right',
        width = 288,
        height = 192,
        vertical_offset = 10,
    }

    if window:is_focused() then
        window:set_config_overrides({ background = {background_layer, image_layer}})
    else
        window:set_config_overrides({ background = {background_layer}})
    end
end)

config.keys = require('keybinds').keys
config.key_tables = require('keybinds').key_tables

return config
