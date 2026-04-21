{ pkgs }: {
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

    "$mod CTRL, 1, workspace, 1"
    "$mod CTRL, 2, workspace, 2"
    "$mod CTRL, 3, workspace, 3"
  ];
  bindm = [ "$mod, mouse:272, moveWindow" "$mod, mouse:273, resizeWindow" ];
  general = {
    gaps_in = 5;
    gaps_out = 10;
    border_size = 2;
  };
  animations = { enabled = true; };
  xwayland = { force_zero_scaling = true; };
}
