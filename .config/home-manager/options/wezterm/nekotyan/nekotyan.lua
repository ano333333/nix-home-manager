-- ========================================
-- フォーカスとキーによる背景画像変更
-- `loadfile(filename)`を使用し直接実行すること
-- @example
--
-- ```lua
-- local chunk, err = loadfile('nekotyan.lua')
-- if chunk ~= nil then
--     chunk()
-- else
--     wezterm.log_error(err)
-- end
-- ```
-- 
-- またキーコンフィグで、頭撫でに設定するキーから'nekotyan:start-headpat'イベントを搬出すること
-- @example
--
-- ```lua
-- { key = 'A', mods = 'CTRL', action = act.EmitEvent 'nekotyan:start-headpat' },
-- ```
-- ========================================
local wezterm = require 'wezterm'
local act = wezterm.action

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

-- 瞬き中の目をつぶっている状態か
local blinking = false

-- 表示中の頭撫でフィニッシュイラストのインデックス(1, 2)
-- 非表示は0
local headpat_finished = 0

-- 一度でもupdate-statusイベントが発生したらマウント処理が行われたと解釈する
local mounted = false

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

local image_layer_default = image_layer('nekotyan/image.png')
local image_layer_enter_pressed = image_layer('nekotyan/image-enter-pressed.png')
local image_layer_headpat_center = image_layer('nekotyan/image-headpat-center.png')
local image_layer_headpat_left = image_layer('nekotyan/image-headpat-left.png')
local image_layer_headpat_right = image_layer('nekotyan/image-headpat-right.png')
local image_layer_headpat_finished_1 = image_layer('nekotyan/image-headpat-finished-1.png')
local image_layer_headpat_finished_2 = image_layer('nekotyan/image-headpat-finished-2.png')

-- 背景画像を変更する。フォーカスが当たっているのときのみ背景画像を表示
function set_background(window, pane)
    if window:is_focused() then
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
        elseif blinking then
            window:set_config_overrides({ background = {background_layer, image_layer_headpat_center}})
        else
            window:set_config_overrides({ background = {background_layer, image_layer_default}})
        end
    else
        window:set_config_overrides({ background = {background_layer}})
    end
end

wezterm.on('nekotyan:off-command-enter', function(window, pane, name, value)
    command_enter_pressed = false
    set_background(window, pane)
end)

-- Enterキー押下を直接拾うとmacOSでIMEがEnterを受け取れなくなるため
-- shell integrationでコマンド実行タイミングを拾う
wezterm.on('user-var-changed', function(window, pane, name, value)
    -- 空行以外のコマンドを実行すると、value='実行コマンド'とvalue=''で2回WEZTERM_PROGイベントが発生するため、その初回のみを拾う
    -- limitation: 空行でコマンドを実行すると、猫ちゃんが応答しない
    if name == 'WEZTERM_PROG' and value ~= '' then
        command_enter_pressed = true
        set_background(window, pane)
        wezterm.time.call_after(0.75, function()
            wezterm.emit('nekotyan:off-command-enter', window, pane)
        end)
    end
end)

-- 瞬き

wezterm.on('nekotyan:start-blinking', function(window, pane)
    blinking = true
    wezterm.time.call_after(0.2, function()
        wezterm.emit('nekotyan:stop-blinking', window, pane)
    end)
    set_background(window, pane)
end)

wezterm.on('nekotyan:stop-blinking', function(window, pane)
    blinking = false
    wezterm.time.call_after(5.0, function()
        wezterm.emit('nekotyan:start-blinking', window, pane)
    end)
    set_background(window, pane)
end)

function on_mount(window, pane)
    mounted = true
    wezterm.time.call_after(5.0, function()
        wezterm.emit('nekotyan:start-blinking', window, pane)
    end)
end

-- ウィンドウのフォーカスが変わった時に背景を変更する
wezterm.on('window-focus-changed', function(window, pane)
    set_background(window, pane)
end)

-- -- ステータス(実行中プロセス等)が更新された時に背景を変更する
wezterm.on('update-status', function(window, pane)
    if not mounted then
        on_mount(window, pane)
    end
end)

wezterm.on('nekotyan:turn-off-headpat-finished', function(window, pane)
    headpat_finished = 0
    set_background(window, pane)
end)

-- Ctrl+Shift+Aイベントが0.55秒間途切れたら、csa_countをリセットする
-- (キーを押しっぱなしにした際、1回目と2回目の間隔のみ約0.5秒になるため)
wezterm.on('nekotyan:headpat-call-after', function(window, pane, csa_prev_pressed_time)
    if csa_last_pressed_time == csa_prev_pressed_time then
        if csa_count > 10 then
            headpat_finished = math.random(1, 2)
        else
            headpat_finished = 0
        end
        csa_count = 0
        wezterm.time.call_after(1.5, function()
            wezterm.emit('nekotyan:turn-off-headpat-finished', window, pane)
        end)
    end
    set_background(window, pane)
end)

wezterm.on('nekotyan:headpat-start', function(window, pane)
    headpat_finished = 0
    local now = wezterm.to_string(wezterm.time.now())
    if csa_count == 0 then
    end
    csa_last_pressed_time = now
    csa_count = csa_count + 1
    wezterm.time.call_after(0.55, function()
        wezterm.emit('nekotyan:headpat-call-after', window, pane, now)
    end)
    set_background(window, pane)
end)
