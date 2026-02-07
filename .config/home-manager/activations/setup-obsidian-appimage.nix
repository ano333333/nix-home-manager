# Obsidian AppImageをセットアップし、デスクトップファイルを作成する (Linux only)
{ lib, config, pkgs, ... }:
let
  obsidianAppImage = pkgs.fetchurl {
    url =
      "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.10.6/Obsidian-1.10.6.AppImage";
    sha256 = "162d753076d0610e4dccfdccf391c13af5fcb557ba7574b77f0e90ac3c522b1c";
  };
  obsidianIconPath = ../assets/obsidian-icon.svg;
in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu

    OBSIDIAN_APPIMAGE="${obsidianAppImage}"
    OBSIDIAN_ICON="${obsidianIconPath}"
    OBSIDIAN_DIR="${config.home.homeDirectory}/.local/bin"
    OBSIDIAN_TARGET="$OBSIDIAN_DIR/obsidian.AppImage"
    DESKTOP_DIR="${config.home.homeDirectory}/.local/share/applications"
    DESKTOP_FILE="$DESKTOP_DIR/obsidian.desktop"
    ICONS_DIR="${config.home.homeDirectory}/.local/share/icons"
    ICON_TARGET="$ICONS_DIR/obsidian-icon.svg"

    # .local/binディレクトリを作成
    if [ ! -d "$OBSIDIAN_DIR" ]; then
      echo "Creating $OBSIDIAN_DIR directory..."
      mkdir -p "$OBSIDIAN_DIR"
    fi

    # AppImageをコピーして実行権限を付与
    if [ ! -f "$OBSIDIAN_TARGET" ] || [ "$OBSIDIAN_APPIMAGE" -nt "$OBSIDIAN_TARGET" ]; then
      echo "Setting up Obsidian AppImage..."
      cp "$OBSIDIAN_APPIMAGE" "$OBSIDIAN_TARGET"
      chmod u+x "$OBSIDIAN_TARGET"
      echo "Obsidian AppImage setup complete"
    else
      echo "Obsidian AppImage already up to date"
    fi

    # アイコンをコピー
    if [ ! -d "$ICONS_DIR" ]; then
      echo "Creating $ICONS_DIR directory..."
      mkdir -p "$ICONS_DIR"
    fi

    if [ ! -f "$ICON_TARGET" ] || [ "$OBSIDIAN_ICON" -nt "$ICON_TARGET" ]; then
      echo "Copying Obsidian icon..."
      cp "$OBSIDIAN_ICON" "$ICON_TARGET"
      echo "Obsidian icon copied"
    else
      echo "Obsidian icon already up to date"
    fi

    # デスクトップファイルを作成
    if [ ! -d "$DESKTOP_DIR" ]; then
      echo "Creating $DESKTOP_DIR directory..."
      mkdir -p "$DESKTOP_DIR"
    fi

    echo "Creating Obsidian desktop file..."
    cat > "$DESKTOP_FILE" << 'EOF'
  [Desktop Entry]
  Type=Application
  Name=Obsidian
  Comment=Obsidian - A knowledge base that works on local Markdown files
  Exec=nixGL ${config.home.homeDirectory}/.local/bin/obsidian.AppImage --no-sandbox %u
  Icon=${config.home.homeDirectory}/.local/share/icons/obsidian-icon.svg
  Categories=Office;
  MimeType=x-scheme-handler/obsidian;
  StartupWMClass=obsidian
  EOF
    echo "Obsidian desktop file created at $DESKTOP_FILE"
''
