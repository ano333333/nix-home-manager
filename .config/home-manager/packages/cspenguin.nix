{ pkgs }:
let
  dcomp = import ./cspenguin/dcomp.nix { inherit pkgs; };
  lock = builtins.fromJSON (builtins.readFile ./cspenguin/downloads.json);
  winetricksSource = pkgs.fetchurl {
    inherit (lock.winetricks) url sha256;
  };
  winetricks = pkgs.runCommand "cspenguin-winetricks-f3890f6" {
    nativeBuildInputs = [ pkgs.patch ];
  } ''
    mkdir -p $out/bin
    cp ${winetricksSource} $out/bin/winetricks
    chmod u+w $out/bin/winetricks
    cd $out/bin
    patch -p1 < ${./cspenguin/winetricks.patch}
    chmod +x winetricks
  '';
  source = pkgs.runCommand "cspenguin-source-868d022" {
    nativeBuildInputs = [ pkgs.patch ];
  } ''
    mkdir -p $out/patches/dcomp $out/patches/fonts
    cp ${./cspenguin/upstream/install.sh} $out/install.sh
    cp ${pkgs.wqy_microhei}/share/fonts/truetype/wqy-microhei.ttc \
      $out/patches/fonts/wqy-microhei.ttc
    test -s $out/patches/fonts/wqy-microhei.ttc
    cp ${dcomp}/lib/dcomp.dll $out/patches/dcomp/
    cp ${./cspenguin/downloads.sh} $out/downloads.sh
    cp ${./cspenguin/downloads.json} $out/downloads.json
    chmod u+w $out/install.sh
    cd $out
    patch -p1 < ${./cspenguin/nixos.patch}
    substituteInPlace install.sh --replace-fail '@WINETRICKS@' '${winetricks}/bin/winetricks'
  '';
  entry = pkgs.writeShellScript "cspenguin-entry" ''
    set -euo pipefail
    # A single dedicated prefix avoids path injection into upstream heredocs.
    export WINEPREFIX="$HOME/.wine-csp"
    unset WINESERVER WINEDLLPATH
    case "''${1:-help}" in
      install)
        shift
        exec bash ${source}/install.sh "$@"
        ;;
      paint|studio)
        mode="$1"
        shift
        launcher="$HOME/.local/share/cspenguin/csp-launch.sh"
        [ "$mode" != studio ] || launcher="$HOME/.local/share/cspenguin/clipstudio-launch.sh"
        if [ ! -f "$launcher" ]; then
          echo 'Run cspenguin install first.' >&2
          exit 1
        fi
        exec bash "$launcher" "$@"
        ;;
      shell) shift; exec bash "$@" ;;
      help|--help|-h)
        echo 'cspenguin install [--dry-run|--update|--update-wine|--verbose]'
        echo 'cspenguin paint [file] | studio | shell'
        ;;
      *) echo 'Unknown command; use cspenguin --help.' >&2; exit 2 ;;
    esac
  '';
in pkgs.buildFHSEnv {
  name = "cspenguin";
  multiArch = true;
  # Arch's FreeType requests libbz2.so.1.0; Nix's ldconfig cache indexes
  # bzip2 by its SONAME (libbz2.so.1). Search the compatibility symlink too.
  profile = ''
    export LD_LIBRARY_PATH="/usr/lib64:/usr/lib32''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  '';
  targetPkgs = p: with p; [
    bash coreutils curl wget cacert gnugrep gnused gawk findutils
    gnutar gzip bzip2 xz zstd unzip file cabextract which util-linux
    procps psmisc wmctrl xorg.xprop xdg-utils desktop-file-utils
    fontconfig glibc.bin python3 winetricks
  ];
  multiPkgs = p: with p; [
    freetype fontconfig zlib bzip2 libpng harfbuzz brotli
    libGL libglvnd vulkan-loader libdrm mesa
    alsa-lib libpulseaudio dbus gnutls cups libusb1
    libxkbcommon wayland libxml2 libxslt
    xorg.libX11 xorg.libXext xorg.libXrender xorg.libXrandr
    xorg.libXi xorg.libXcursor xorg.libXfixes xorg.libXinerama
    xorg.libXcomposite xorg.libXdamage xorg.libxcb
    gst_all_1.gstreamer gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good gst_all_1.gst-plugins-bad
    gst_all_1.gst-libav
  ];
  runScript = entry;
  meta.platforms = [ "x86_64-linux" ];
}
