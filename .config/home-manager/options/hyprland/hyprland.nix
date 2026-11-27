{ pkgs }: {
  env = [ "WLR_RENDERER,pixman" ];
  exec-once = [ "${pkgs.hyprpanel}/bin/hyprpanel" ];
  input = { kb_layout = "jp"; };
  "$mod" = "SUPER";
  bind = [
    "$mod CTRL, r, exec, ${pkgs.wofi}/bin/wofi --show drun"
    "$mod CTRL, e, exec, ${pkgs.nautilus}/bin/nautilus"
    "$mod CTRL, t, exec, wezterm"

    "$mod CTRL, q, killactive"

    "$mod SHIFT, H, movefocus, l"
    "$mod SHIFT, L, movefocus, r"
    "$mod SHIFT, K, movefocus, u"
    "$mod SHIFT, J, movefocus, d"

    "$mod CTRL, 1, focusworkspaceoncurrentmonitor, 1"
    "$mod CTRL, 2, focusworkspaceoncurrentmonitor, 2"
    "$mod CTRL, 3, focusworkspaceoncurrentmonitor, 3"
    "$mod CTRL, 4, focusworkspaceoncurrentmonitor, 4"
    "$mod CTRL, 5, focusworkspaceoncurrentmonitor, 5"
    "$mod CTRL, 6, focusworkspaceoncurrentmonitor, 6"
    "$mod CTRL, 7, focusworkspaceoncurrentmonitor, 7"
    "$mod CTRL, 8, focusworkspaceoncurrentmonitor, 8"
    "$mod CTRL, 9, focusworkspaceoncurrentmonitor, 9"
    "$mod CTRL, 0, focusworkspaceoncurrentmonitor, 10"
    "$mod CTRL, L, focusmonitor, r"
    "$mod CTRL, H, focusmonitor, l"
  ];
  bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];
  binds = { drag_threshold = 10; };
  general = {
    gaps_in = 5;
    gaps_out = 10;
    border_size = 2;
  };
  animations = {
    enabled = true;
    animation = [ "workspaces, 1, 5, default, slide" ];
  };
  xwayland = { force_zero_scaling = true; };
}
