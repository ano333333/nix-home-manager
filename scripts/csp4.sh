#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: csp4 COMMAND [ARGS]
  doctor                  Show Wine version, display and prefix (read-only)
  setup                   Create prefix, install fonts and VC++ runtime
  setup-webview2          Install WebView2 135.0.3179.85 and configure it
  setup-dcomp             Install the source-built DirectComposition shim
  restore-dcomp           Restore the DLL and override saved before installation
  install /path/CSP.exe    Run the CSP 4 Windows installer interactively
  paint [ARGS]            Launch CLIP STUDIO PAINT directly
  studio [ARGS]           Launch CLIP STUDIO (login/materials)
  wine ARGS               Run Wine tools/installers in this prefix
  winetricks ARGS          Install optional dependencies in this prefix

Default prefix: ~/.local/share/csp4/wineprefix
Override with an absolute CSP4_PREFIX path. Existing WINEPREFIX is ignored.
See docs/csp4.md for setup, licensing and WebView2 troubleshooting.
EOF
}

action="${1:-help}"
if [[ "$action" == help || "$action" == --help || "$action" == -h ]]; then
  usage
  exit 0
fi
shift
export WINEPREFIX="${CSP4_PREFIX:-${XDG_DATA_HOME:-$HOME/.local/share}/csp4/wineprefix}"
export WINEARCH=win64
[[ "$WINEPREFIX" == /* ]] || { echo 'CSP4_PREFIX must be absolute.' >&2; exit 1; }
# Avoid exporting Windows shortcuts/file associations into the host desktop.
export WINEDLLOVERRIDES="winemenubuilder.exe=d${WINEDLLOVERRIDES:+;$WINEDLLOVERRIDES}"

require_prefix() {
  [[ -f "$WINEPREFIX/system.reg" ]] || {
    echo 'Run csp4 setup first.' >&2
    exit 1
  }
}

compatibility() {
  wine reg add 'HKCU\Software\Wine' /v Version /t REG_SZ /d win10 /f
  for exe in CLIPStudioPaint.exe CLIPStudio.exe; do
    wine reg add "HKCU\Software\Wine\AppDefaults\$exe" \
      /v Version /t REG_SZ /d win81 /f
  done
  wine reg add 'HKCU\Software\Wine\DllOverrides' \
    /v concrt140 /t REG_SZ /d native,builtin /f
}

case "$action" in
  doctor)
    wine --version
    printf 'Prefix: %s\nDISPLAY: %s\nWAYLAND_DISPLAY: %s\n' \
      "$WINEPREFIX" "${DISPLAY:-unset}" "${WAYLAND_DISPLAY:-unset}"
    if [[ -f "$WINEPREFIX/system.reg" ]]; then
      find "$WINEPREFIX/drive_c" -type f \
        \( -iname 'CLIPStudioPaint.exe' -o -iname 'CLIPStudio.exe' \
        -o -iname 'msedgewebview2.exe' \)
    else
      echo 'Prefix is not initialized.'
    fi
    ;;
  setup)
    mkdir -p "$WINEPREFIX"
    wineboot --init
    wineserver -w
    winetricks -q corefonts cjkfonts vcrun2022
    compatibility
    echo 'Base setup complete. Next: csp4 install /absolute/path/to/CSP_40Xw_setup.exe'
    ;;
  setup-dcomp|restore-dcomp)
    require_prefix
    [[ $# -eq 0 ]] || { usage >&2; exit 1; }
    # Refuse live replacement; never terminate a user's drawing session.
    if pgrep -i '^(CLIPStudio|msedgewebview)' >/dev/null; then
      echo 'Close CSP, CLIP STUDIO and WebView2 before changing dcomp.' >&2
      exit 1
    fi
    backup="$WINEPREFIX/csp-dcomp-backup"
    target="$WINEPREFIX/drive_c/windows/system32/dcomp.dll"
    key='HKCU\Software\Wine\DllOverrides'
    if [[ "$action" == setup-dcomp ]]; then
      [[ -f "${CSP_DCOMP_DLL:-}" ]] || { echo 'Use the Nix csp4 app to build the DLL.' >&2; exit 1; }
      if [[ ! -d "$backup" ]]; then
        # Query the key first so an unavailable registry is not treated as an absent value.
        wine reg query "$key" >/dev/null
        scratch="$(mktemp -d "$WINEPREFIX/.dcomp-backup.XXXXXX")"
        if wine reg query "$key" /v dcomp > "$scratch/query.txt" 2>/dev/null; then
          value="$(sed -n 's/.*REG_SZ[[:space:]]*//p' "$scratch/query.txt" | tr -d '\r')"
          [[ "$value" =~ ^[a-z,[:space:]]*$ ]] || { echo 'Unexpected dcomp override; aborting.' >&2; exit 1; }
          printf '%s' "$value" > "$scratch/override"
        fi
        if [[ -e "$target" ]]; then cp -L "$target" "$scratch/dcomp.dll"; fi
        mv "$scratch" "$backup"
      fi
      # Use rename so a possible symlink/hardlink to a Wine file is never overwritten.
      install -m 644 "$CSP_DCOMP_DLL" "$target.csp-new"
      mv -f "$target.csp-new" "$target"
      wine reg add "$key" /v dcomp /t REG_SZ /d native,builtin /f
      echo "Source-built dcomp installed. Backup: $backup"
    else
      [[ -d "$backup" ]] || { echo 'No dcomp backup found.' >&2; exit 1; }
      if [[ -f "$backup/dcomp.dll" ]]; then
        install -m 644 "$backup/dcomp.dll" "$target.csp-restore"
        mv -f "$target.csp-restore" "$target"
      else
        rm -f "$target"
      fi
      if [[ -f "$backup/override" ]]; then
        wine reg add "$key" /v dcomp /t REG_SZ /d "$(cat "$backup/override")" /f
      elif wine reg query "$key" /v dcomp >/dev/null 2>&1; then
        wine reg delete "$key" /v dcomp /f
      fi
      echo 'Original dcomp restored; backup retained.'
    fi
    ;;
  setup-webview2)
    require_prefix
    [[ $# -eq 0 ]] || { usage >&2; exit 1; }
    version=135.0.3179.85
    runtime="$(find "$WINEPREFIX/drive_c" -type f \
      -path "*/EdgeWebView/Application/$version/msedgewebview2.exe" -print -quit)"
    if [[ -z "$runtime" ]]; then
      cache="${XDG_CACHE_HOME:-$HOME/.cache}/csp4/webview2/$version"
      mkdir -p "$cache"
      installer="$cache/MicrosoftEdgeWebView2RuntimeInstallerX64.exe"
      if [[ ! -f "$installer" ]]; then
        curl --fail --location --retry 3 --proto '=https' --proto-redir '=https' \
          'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/76eb3dc4-7851-45b7-a392-460523b0e2bb/MicrosoftEdgeWebView2RuntimeInstallerX64.exe' \
          --output "$installer.part"
        mv "$installer.part" "$installer"
      fi
      echo 'Close CSP and CLIP STUDIO before installing WebView2.'
      echo "Installer log: $cache/install.log"
      # Wait for the installer, not a fixed timer; never kill other Wine apps.
      wine "$installer" /silent /install 2>&1 | tee "$cache/install.log"
      runtime="$(find "$WINEPREFIX/drive_c" -type f \
        -path "*/EdgeWebView/Application/$version/msedgewebview2.exe" -print -quit)"
      [[ -n "$runtime" ]] || {
        echo "WebView2 $version executable was not found. Check $cache/install.log" >&2
        exit 1
      }
    fi
    wine reg add 'HKCU\Software\Wine\AppDefaults\msedgewebview2.exe' \
      /v Version /t REG_SZ /d win7 /f
    printf 'WebView2 executable found: %s\nCompatibility: win7 (WebView2 only).\n' "$runtime"
    echo 'Restart CSP to test the login window; rendering is not verified by this command.'
    ;;
  install)
    require_prefix
    [[ $# -eq 1 && -f "$1" ]] || { usage >&2; exit 1; }
    installer="$(realpath "$1")"
    wine "$installer"
    # Do not wait for all Wine processes: the installer may start the launcher.
    compatibility
    ;;
  paint|studio)
    require_prefix
    name=CLIPStudioPaint.exe
    [[ "$action" != studio ]] || name=CLIPStudio.exe
    exe="$(find "$WINEPREFIX/drive_c/Program Files" -type f -iname "$name" -print -quit)"
    [[ -n "$exe" ]] || { echo "$name not found; install CSP first." >&2; exit 1; }
    cd "$(dirname "$exe")"
    exec wine "$exe" "$@"
    ;;
  wine|winetricks)
    require_prefix
    [[ $# -gt 0 ]] || { usage >&2; exit 1; }
    exec "$action" "$@"
    ;;
  *) usage >&2; exit 1 ;;
esac
