{ pkgs }: {
  exec-once = [ "${pkgs.hyprpanel}/bin/hyprpanel" ];
  input = { kb_layout = "jp"; };
  "$mod" = "SUPER";
  bind = [
    "$mod, R, exec, ${pkgs.wofi}/bin/wofi --show drun"
    "$mod, F, exec, ${pkgs.nautilus}/bin/nautilus"
  ];
}
