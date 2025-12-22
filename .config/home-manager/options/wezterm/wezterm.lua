local wezterm = require 'wezterm'
local act = wezterm.action

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

-- ========================================
-- フォーカスとキーによる背景画像変更
-- ========================================

-- Enterキー押下イベントが発生したか
local enter_pressed = false

local background_layer = {
    source = {
        Color = 'black'
    },
    width = '100%',
    height = '100%',
}
local image_layer_default = {
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
local image_layer_enter_pressed = {
    source = {
        File = '/home/ano3/.config/wezterm/image-enter-pressed.png'
    },
    opacity = 0.3,
    vertical_align = 'Bottom',
    horizontal_align = 'Right',
    width = 288,
    height = 192,
    vertical_offset = 10,
}

-- 背景画像を変更する
-- - フォーカスが当たっている
-- - プロセス名が「/bin/zsh」を含む
-- のときのみ背景画像を表示
function set_background(window, pane)
    local process_name = pane:get_foreground_process_name()
    if window:is_focused() and process_name and process_name:find('/bin/zsh') then
        if enter_pressed then
            window:set_config_overrides({ background = {background_layer, image_layer_enter_pressed}})
        else
            window:set_config_overrides({ background = {background_layer, image_layer_default}})
        end
    else
        window:set_config_overrides({ background = {background_layer}})
    end
end

wezterm.on('off-enter', function(window, pane)
    enter_pressed = false
    set_background(window, pane)
end)

wezterm.on('press-enter', function(window, pane)
    enter_pressed = true
    set_background(window, pane)
    wezterm.time.call_after(0.75, function()
        wezterm.emit('off-enter', window, pane)
    end)
    window:perform_action(act.SendKey { key = 'Enter'}, pane)
end)

-- ウィンドウのフォーカスが変わった時に背景を変更する
wezterm.on('window-focus-changed', function(window, pane)
    set_background(window, pane)
end)

-- -- ステータス(実行中プロセス等)が更新された時に背景を変更する
wezterm.on('update-status', function(window, pane)
    set_background(window, pane)
end)

config.keys = require('keybinds').keys
config.key_tables = require('keybinds').key_tables

return config
