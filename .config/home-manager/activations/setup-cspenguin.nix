{ lib, config, pkgs }:
let
  cspenguin = import ../packages/cspenguin.nix { inherit pkgs; };
  paintDesktop = pkgs.writeText "cspenguin-paint.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Clip Studio Paint
    Exec=${cspenguin}/bin/cspenguin paint %f
    Terminal=false
    Categories=Graphics;
    MimeType=application/x-clip;
    StartupWMClass=clipstudiopaint.exe
    Icon=applications-graphics
  '';
  studioDesktop = pkgs.writeText "cspenguin-studio.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=CLIP STUDIO
    Exec=${cspenguin}/bin/cspenguin studio
    Terminal=false
    Categories=Graphics;
    StartupWMClass=clipstudio.exe
    Icon=applications-graphics
  '';
  setup = pkgs.writeShellApplication {
    name = "cspenguin-setup";
    runtimeInputs = [ pkgs.coreutils pkgs.util-linux pkgs.xterm ];
    text = ''
      installed() {
        test -f "$HOME/.wine-csp/drive_c/Program Files/CELSYS/CLIP STUDIO 1.5/CLIP STUDIO PAINT/CLIPStudioPaint.exe" &&
        test -f "$HOME/.local/share/cspenguin/csp-launch.sh" &&
        test -f "$HOME/.local/share/cspenguin/clipstudio-launch.sh"
      }
      autostart="$HOME/.config/autostart/cspenguin-setup.desktop"
      if installed; then
        rm -f "$autostart"
        exit 0
      fi
      if [ "''${1:-}" = --check ]; then
        exit 1
      fi
      if [ "''${1:-}" != --install ]; then
        exec xterm -T 'CSPenguin setup' -e "$0" --install
      fi
      mkdir -p "$HOME/.local/share/cspenguin"
      exec 9>"$HOME/.local/share/cspenguin/setup.lock"
      flock -n 9 || exit 0
      installed && exit 0
      if ${cspenguin}/bin/cspenguin install && installed; then
        rm -f "$autostart"
      else
        echo 'Setup did not complete. Run cspenguin install to retry.'
        read -r -p 'Press Enter to close this window. ' || true
        exit 1
      fi
    '';
  };
in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  if [ -z "''${DRY_RUN_CMD:-}" ]; then
    ${pkgs.coreutils}/bin/install -Dm644 ${paintDesktop} \
      "${config.home.homeDirectory}/.local/share/applications/cspenguin-paint.desktop"
    ${pkgs.coreutils}/bin/install -Dm644 ${studioDesktop} \
      "${config.home.homeDirectory}/.local/share/applications/cspenguin-studio.desktop"
    ${pkgs.desktop-file-utils}/bin/update-desktop-database \
      "${config.home.homeDirectory}/.local/share/applications"
    if ! ${setup}/bin/cspenguin-setup --check; then
      # NixOS activation has no desktop environment or terminal. Keep a login
      # fallback and use the user manager's environment for immediate setup.
      mkdir -p "${config.home.homeDirectory}/.config/autostart"
      cat > "${config.home.homeDirectory}/.config/autostart/cspenguin-setup.desktop" <<'EOF'
  [Desktop Entry]
  Type=Application
  Name=CSPenguin initial setup
  Exec=${setup}/bin/cspenguin-setup
  Terminal=false
  EOF
      if [ -n "''${DISPLAY:-}" ]; then
        ${pkgs.systemd}/bin/systemd-run --user --collect --unit=cspenguin-setup \
          --setenv="DISPLAY=$DISPLAY" --setenv="XAUTHORITY=''${XAUTHORITY:-}" \
          ${setup}/bin/cspenguin-setup || true
      elif ${pkgs.systemd}/bin/systemctl --user show-environment 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q '^DISPLAY=.'; then
        ${pkgs.systemd}/bin/systemd-run --user --collect --unit=cspenguin-setup \
          ${setup}/bin/cspenguin-setup || true
      else
        echo 'CSPenguin setup will open on the next desktop login.'
      fi
    fi
  fi
''
