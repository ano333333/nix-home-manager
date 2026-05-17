# PenCil AppImageはバージョン付されていない単一URLからしかダウンロードできないので、
# このActivation実行時に逐次ダウンロードしインストールする
{ lib, config, pkgs, ... }:
lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  set -eu

  PENCIL_URL="https://www.pencil.dev/download/Pencil-linux-x86_64.AppImage"
  PENCIL_DIR="${config.home.homeDirectory}/.local/share/pencil"
  PENCIL_TARGET="$PENCIL_DIR/Pencil.AppImage"
  DESKTOP_DIR="${config.home.homeDirectory}/.local/share/applications"
  DESKTOP_FILE="$DESKTOP_DIR/pencil.desktop"

  if [ -f "$PENCIL_TARGET" ]; then
    echo "Pencil AppImage already installed"
  else
    echo "Installing Pencil AppImage..."
    mkdir -p "$PENCIL_DIR"
    ${pkgs.curl}/bin/curl -fL "$PENCIL_URL" -o "$PENCIL_TARGET"
    chmod u+x "$PENCIL_TARGET"
    echo "Pencil AppImage installed at $PENCIL_TARGET"
  fi

    mkdir -p "$DESKTOP_DIR"
    cat > "$DESKTOP_FILE" << 'EOF'
  [Desktop Entry]
  Type=Application
  Name=Pencil
  Comment=Pencil GUI
  Exec=pencil-gui %U
  Terminal=false
  Categories=Graphics;Office;
  StartupNotify=true
  EOF
    echo "Pencil desktop file created at $DESKTOP_FILE"
''
