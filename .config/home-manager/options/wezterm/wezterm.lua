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

math.randomseed(os.time())

local background_opacity = 1.0
if wezterm.target_triple == 'aarch64-apple-darwin' then
    background_opacity = 0.85
end

-- Enterキー押下イベントが発生したか
local command_enter_pressed = false

-- 最後にCtrl+Shift+Aイベントがemitされた時刻の文字列
local csa_last_pressed_time = '0'
-- Ctrl+Shift+Aイベントが何回連続でemitされたか
local csa_count = 0

-- 表示中の頭撫でフィニッシュイラストのインデックス(1, 2)
-- 非表示は0
local headpat_finished = 0

local background_layer = {
    source = {
        Color = '#202020'
    },
    opacity = background_opacity,
    width = '100%',
    height = '100%',
}

function image_layer(name)
    return {
        source = {
            File = wezterm.config_dir .. '/' .. name
        },
        opacity = 0.5,
        vertical_align = 'Bottom',
        horizontal_align = 'Right',
        width = 288,
        height = 192,
        vertical_offset = 10,
    }
end

local image_layer_default = image_layer('image.png')
local image_layer_enter_pressed = image_layer('image-enter-pressed.png')
local image_layer_headpat_center = image_layer('image-headpat-center.png')
local image_layer_headpat_left = image_layer('image-headpat-left.png')
local image_layer_headpat_right = image_layer('image-headpat-right.png')
local image_layer_headpat_finished_1 = image_layer('image-headpat-finished-1.png')
local image_layer_headpat_finished_2 = image_layer('image-headpat-finished-2.png')

-- 背景画像を変更する
-- - フォーカスが当たっている
-- - プロセス名が「/bin/zsh」を含む
-- のときのみ背景画像を表示
function set_background(window, pane)
    local process_name = pane:get_foreground_process_name()
    if window:is_focused() and process_name and process_name:find('/bin/zsh') then
        if headpat_finished == 1 then
            window:set_config_overrides({ background = {background_layer, image_layer_headpat_finished_1}})
        elseif headpat_finished == 2 then
            window:set_config_overrides({ background = {background_layer, image_layer_headpat_finished_2}})
        elseif csa_count > 0 then
            -- 頭撫でアニメーションの表示
            -- 15回呼び出しごとにイラストを切り替える
            -- イラストは中左中右中左中右...の順で表示
            local frame = (csa_count - csa_count % 15) / 15
            if frame % 2 == 0 then
                window:set_config_overrides({ background = {background_layer, image_layer_headpat_center}})
            elseif frame % 4 == 1 then
                window:set_config_overrides({ background = {background_layer, image_layer_headpat_left}})
            else
                window:set_config_overrides({ background = {background_layer, image_layer_headpat_right}})
            end
        elseif command_enter_pressed then
            window:set_config_overrides({ background = {background_layer, image_layer_enter_pressed}})
        else
            window:set_config_overrides({ background = {background_layer, image_layer_default}})
        end
    else
        window:set_config_overrides({ background = {background_layer}})
    end
end

wezterm.on('off-command-enter', function(window, pane, name, value)
    command_enter_pressed = false
    set_background(window, pane)
end)

-- Enterキー押下を直接拾うとmacOSでIMEがEnterを受け取れなくなるため
-- shell integrationでコマンド実行タイミングを拾う
wezterm.on('user-var-changed', function(window, pane, name, value)
    if name == 'WEZTERM_PROG' then
        command_enter_pressed = true
        set_background(window, pane)
        wezterm.time.call_after(0.75, function()
            wezterm.emit('off-command-enter', window, pane)
        end)
    end
end)

-- ウィンドウのフォーカスが変わった時に背景を変更する
wezterm.on('window-focus-changed', function(window, pane)
    set_background(window, pane)
end)

-- -- ステータス(実行中プロセス等)が更新された時に背景を変更する
wezterm.on('update-status', function(window, pane)
    set_background(window, pane)
end)

wezterm.on('turn-off-headpat-finished', function(window, pane)
    headpat_finished = 0
    set_background(window, pane)
end)

-- Ctrl+Shift+Aイベントが0.55秒間途切れたら、csa_countをリセットする
-- (キーを押しっぱなしにした際、1回目と2回目の間隔のみ約0.5秒になるため)
wezterm.on('press-c-s-a-call_after', function(window, pane, csa_prev_pressed_time)
    if csa_last_pressed_time == csa_prev_pressed_time then
        if csa_count > 10 then
            headpat_finished = math.random(1, 2)
        else
            headpat_finished = 0
        end
        csa_count = 0
        wezterm.time.call_after(1.5, function()
            wezterm.emit('turn-off-headpat-finished', window, pane)
        end)
    end
    set_background(window, pane)
end)

wezterm.on('press-c-s-a', function(window, pane)
    headpat_finished = 0
    local now = wezterm.to_string(wezterm.time.now())
    if csa_count == 0 then
    end
    csa_last_pressed_time = now
    csa_count = csa_count + 1
    wezterm.time.call_after(0.55, function()
        wezterm.emit('press-c-s-a-call_after', window, pane, now)
    end)
    set_background(window, pane)
end)

config.keys = require('keybinds').keys
config.key_tables = require('keybinds').key_tables

return config
