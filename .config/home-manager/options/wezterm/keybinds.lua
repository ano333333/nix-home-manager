local wezterm = require("wezterm")
local act = wezterm.action

return {
  keys = {
    -- ========================================
    -- ウィンドウ
    --
    -- SHIFT+CTRL+nで新しいウィンドウを開く
    -- ========================================
    { key = "n", mods = "SHIFT|CTRL", action = act.SpawnWindow },
    { key = "n", mods = "SUPER", action = act.SpawnWindow },
    { key = "N", mods = "CTRL", action = act.SpawnWindow },
    { key = "N", mods = "SHIFT|CTRL", action = act.SpawnWindow },

    -- ========================================
    -- コピー&ペースト
    --
    -- SHIFT+CTRL+cでコピー
    -- SHIFT+CTRL+vでペースト
    -- SHIFT+CTRL+xでコピーモードを起動
    -- ========================================
    {
      key = "c",
      mods = "SHIFT|CTRL",
      action = act.CopyTo("Clipboard"),
    },
    {
      key = "c",
      mods = "SUPER",
      action = act.CopyTo("Clipboard"),
    },
    {
      key = "C",
      mods = "CTRL",
      action = act.CopyTo("Clipboard"),
    },
    {
      key = "v",
      mods = "SHIFT|CTRL",
      action = act.PasteFrom("Clipboard"),
    },
    {
      key = "v",
      mods = "SUPER",
      action = act.PasteFrom("Clipboard"),
    },
    {
      key = "V",
      mods = "CTRL",
      action = act.PasteFrom("Clipboard"),
    },
    { key = "x", mods = "SHIFT|CTRL", action = act.ActivateCopyMode },
    { key = "X", mods = "CTRL", action = act.ActivateCopyMode },

    -- ========================================
    -- フォントサイズ
    --
    -- SHIFT+CTRL+;でフォントサイズを増やす
    -- SHIFT+CTRL+-でフォントサイズを減らす
    -- SHIFT+CTRL+0でフォントサイズをリセット
    -- ========================================
    { key = ";", mods = "SHIFT|CTRL", action = act.IncreaseFontSize },
    { key = "+", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "SHIFT|CTRL", action = act.DecreaseFontSize },
    { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "0", mods = "SHIFT|CTRL", action = act.ResetFontSize },

    -- ========================================
    -- 独自イベント
    --
    -- Ctrl+Shift+Aで頭撫でを開始
    -- Ctrl+Shift+k/SUPER+kでチートシートを開く
    -- ========================================
    {
      key = "A",
      mods = "CTRL",
      action = act.EmitEvent("nekotyan:headpat-start"),
    },
    {
      key = "K",
      mods = "SHIFT|CTRL",
      action = wezterm.action_callback(function(window, _)
        local cheatsheet = require("./cheatsheet")
        cheatsheet.ToggleCheatsheet(window)
      end),
    },
    {
      key = "k",
      mods = "SUPER",
      action = wezterm.action_callback(function(window, _)
        local cheatsheet = require("./cheatsheet")
        cheatsheet.ToggleCheatsheet(window)
      end),
    },

    -- ========================================
    -- その他
    -- ========================================
    { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },
    {
      key = "F",
      mods = "CTRL",
      action = act.Search("CurrentSelectionOrEmptyString"),
    },
    {
      key = "F",
      mods = "SHIFT|CTRL",
      action = act.Search("CurrentSelectionOrEmptyString"),
    },
    { key = "L", mods = "CTRL", action = act.ShowDebugOverlay },
    { key = "L", mods = "SHIFT|CTRL", action = act.ShowDebugOverlay },
    { key = "M", mods = "CTRL", action = act.Hide },
    { key = "M", mods = "SHIFT|CTRL", action = act.Hide },
    {
      key = "P",
      mods = "CTRL",
      action = act.ActivateCommandPalette,
    },
    {
      key = "P",
      mods = "SHIFT|CTRL",
      action = act.ActivateCommandPalette,
    },
    {
      key = "R",
      mods = "CTRL",
      action = act.ReloadConfiguration,
    },
    {
      key = "R",
      mods = "SHIFT|CTRL",
      action = act.ReloadConfiguration,
    },
    {
      key = "U",
      mods = "CTRL",
      action = act.CharSelect({
        copy_on_select = true,
        copy_to = "ClipboardAndPrimarySelection",
      }),
    },
    {
      key = "U",
      mods = "SHIFT|CTRL",
      action = act.CharSelect({
        copy_on_select = true,
        copy_to = "ClipboardAndPrimarySelection",
      }),
    },
    { key = "_", mods = "CTRL", action = act.DecreaseFontSize },
    { key = "_", mods = "SHIFT|CTRL", action = act.DecreaseFontSize },
    {
      key = "f",
      mods = "SHIFT|CTRL",
      action = act.Search("CurrentSelectionOrEmptyString"),
    },
    {
      key = "f",
      mods = "SUPER",
      action = act.Search("CurrentSelectionOrEmptyString"),
    },
    { key = "l", mods = "SHIFT|CTRL", action = act.ShowDebugOverlay },
    { key = "m", mods = "SHIFT|CTRL", action = act.Hide },
    { key = "m", mods = "SUPER", action = act.Hide },
    {
      key = "p",
      mods = "SHIFT|CTRL",
      action = act.ActivateCommandPalette,
    },
    {
      key = "r",
      mods = "SHIFT|CTRL",
      action = act.ReloadConfiguration,
    },
    {
      key = "r",
      mods = "SUPER",
      action = act.ReloadConfiguration,
    },
    {
      key = "u",
      mods = "SHIFT|CTRL",
      action = act.CharSelect({
        copy_on_select = true,
        copy_to = "ClipboardAndPrimarySelection",
      }),
    },
    { key = "phys:Space", mods = "SHIFT|CTRL", action = act.QuickSelect },
    { key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
    { key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
    {
      key = "Insert",
      mods = "SHIFT",
      action = act.PasteFrom("PrimarySelection"),
    },
    {
      key = "Insert",
      mods = "CTRL",
      action = act.CopyTo("PrimarySelection"),
    },
    {
      key = "Copy",
      mods = "NONE",
      action = act.CopyTo("Clipboard"),
    },
    {
      key = "Paste",
      mods = "NONE",
      action = act.PasteFrom("Clipboard"),
    },
  },

  key_tables = {
    copy_mode = {
      {
        key = "Tab",
        mods = "NONE",
        action = act.CopyMode("MoveForwardWord"),
      },
      {
        key = "Tab",
        mods = "SHIFT",
        action = act.CopyMode("MoveBackwardWord"),
      },
      {
        key = "Enter",
        mods = "NONE",
        action = act.CopyMode("MoveToStartOfNextLine"),
      },
      {
        key = "Escape",
        mods = "NONE",
        action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }),
      },
      {
        key = "Space",
        mods = "NONE",
        action = act.CopyMode({ SetSelectionMode = "Cell" }),
      },
      {
        key = "$",
        mods = "NONE",
        action = act.CopyMode("MoveToEndOfLineContent"),
      },
      {
        key = "$",
        mods = "SHIFT",
        action = act.CopyMode("MoveToEndOfLineContent"),
      },
      {
        key = ",",
        mods = "NONE",
        action = act.CopyMode("JumpReverse"),
      },
      {
        key = "0",
        mods = "NONE",
        action = act.CopyMode("MoveToStartOfLine"),
      },
      { key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
      {
        key = "F",
        mods = "NONE",
        action = act.CopyMode({ JumpBackward = { prev_char = false } }),
      },
      {
        key = "F",
        mods = "SHIFT",
        action = act.CopyMode({ JumpBackward = { prev_char = false } }),
      },
      {
        key = "G",
        mods = "NONE",
        action = act.CopyMode("MoveToScrollbackBottom"),
      },
      {
        key = "G",
        mods = "SHIFT",
        action = act.CopyMode("MoveToScrollbackBottom"),
      },
      {
        key = "H",
        mods = "NONE",
        action = act.CopyMode("MoveToViewportTop"),
      },
      {
        key = "H",
        mods = "SHIFT",
        action = act.CopyMode("MoveToViewportTop"),
      },
      {
        key = "L",
        mods = "NONE",
        action = act.CopyMode("MoveToViewportBottom"),
      },
      {
        key = "L",
        mods = "SHIFT",
        action = act.CopyMode("MoveToViewportBottom"),
      },
      {
        key = "M",
        mods = "NONE",
        action = act.CopyMode("MoveToViewportMiddle"),
      },
      {
        key = "M",
        mods = "SHIFT",
        action = act.CopyMode("MoveToViewportMiddle"),
      },
      {
        key = "O",
        mods = "NONE",
        action = act.CopyMode("MoveToSelectionOtherEndHoriz"),
      },
      {
        key = "O",
        mods = "SHIFT",
        action = act.CopyMode("MoveToSelectionOtherEndHoriz"),
      },
      {
        key = "T",
        mods = "NONE",
        action = act.CopyMode({ JumpBackward = { prev_char = true } }),
      },
      {
        key = "T",
        mods = "SHIFT",
        action = act.CopyMode({ JumpBackward = { prev_char = true } }),
      },
      {
        key = "V",
        mods = "NONE",
        action = act.CopyMode({ SetSelectionMode = "Line" }),
      },
      {
        key = "V",
        mods = "SHIFT",
        action = act.CopyMode({ SetSelectionMode = "Line" }),
      },
      {
        key = "^",
        mods = "NONE",
        action = act.CopyMode("MoveToStartOfLineContent"),
      },
      {
        key = "^",
        mods = "SHIFT",
        action = act.CopyMode("MoveToStartOfLineContent"),
      },
      {
        key = "b",
        mods = "NONE",
        action = act.CopyMode("MoveBackwardWord"),
      },
      {
        key = "b",
        mods = "ALT",
        action = act.CopyMode("MoveBackwardWord"),
      },
      { key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
      {
        key = "c",
        mods = "CTRL",
        action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }),
      },
      {
        key = "d",
        mods = "CTRL",
        action = act.CopyMode({ MoveByPage = 0.5 }),
      },
      {
        key = "e",
        mods = "NONE",
        action = act.CopyMode("MoveForwardWordEnd"),
      },
      {
        key = "f",
        mods = "NONE",
        action = act.CopyMode({ JumpForward = { prev_char = false } }),
      },
      {
        key = "f",
        mods = "ALT",
        action = act.CopyMode("MoveForwardWord"),
      },
      { key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
      {
        key = "g",
        mods = "NONE",
        action = act.CopyMode("MoveToScrollbackTop"),
      },
      {
        key = "g",
        mods = "CTRL",
        action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }),
      },
      { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
      { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
      { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
      { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
      {
        key = "m",
        mods = "ALT",
        action = act.CopyMode("MoveToStartOfLineContent"),
      },
      {
        key = "o",
        mods = "NONE",
        action = act.CopyMode("MoveToSelectionOtherEnd"),
      },
      {
        key = "q",
        mods = "NONE",
        action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }),
      },
      {
        key = "t",
        mods = "NONE",
        action = act.CopyMode({ JumpForward = { prev_char = true } }),
      },
      {
        key = "u",
        mods = "CTRL",
        action = act.CopyMode({ MoveByPage = -0.5 }),
      },
      {
        key = "v",
        mods = "NONE",
        action = act.CopyMode({ SetSelectionMode = "Cell" }),
      },
      {
        key = "v",
        mods = "CTRL",
        action = act.CopyMode({ SetSelectionMode = "Block" }),
      },
      {
        key = "w",
        mods = "NONE",
        action = act.CopyMode("MoveForwardWord"),
      },
      {
        key = "y",
        mods = "NONE",
        action = act.Multiple({
          { CopyTo = "ClipboardAndPrimarySelection" },
          { Multiple = { "ScrollToBottom", { CopyMode = "Close" } } },
        }),
      },
      { key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
      { key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
      {
        key = "End",
        mods = "NONE",
        action = act.CopyMode("MoveToEndOfLineContent"),
      },
      {
        key = "Home",
        mods = "NONE",
        action = act.CopyMode("MoveToStartOfLine"),
      },
      { key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
      {
        key = "LeftArrow",
        mods = "ALT",
        action = act.CopyMode("MoveBackwardWord"),
      },
      { key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
      {
        key = "RightArrow",
        mods = "ALT",
        action = act.CopyMode("MoveForwardWord"),
      },
      { key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
      { key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
    },

    search_mode = {
      { key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
      { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
      { key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
      { key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
      {
        key = "r",
        mods = "CTRL",
        action = act.CopyMode("CycleMatchType"),
      },
      {
        key = "u",
        mods = "CTRL",
        action = act.CopyMode("ClearPattern"),
      },
      {
        key = "PageUp",
        mods = "NONE",
        action = act.CopyMode("PriorMatchPage"),
      },
      {
        key = "PageDown",
        mods = "NONE",
        action = act.CopyMode("NextMatchPage"),
      },
      { key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
      { key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
    },
  },
}
