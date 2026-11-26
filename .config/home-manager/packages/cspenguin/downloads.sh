# Sourced by the patched installer. The manifest belongs to the Nix store.
locked_download() (
    set -euo pipefail
    url="$1"
    dest="$2"
    expected=$(python3 - "$SCRIPT_DIR/downloads.json" "$url" <<'PY'
import json, sys
items = json.load(open(sys.argv[1]))
matches = [v['sha256'] for v in items.values() if v['url'] == sys.argv[2]]
if len(matches) != 1:
    sys.exit('URL is not in the reviewed download manifest')
print(matches[0])
PY
    ) || exit 1
    verify() {
        [ -f "$1" ] && [ "$(sha256sum -- "$1" | cut -d ' ' -f 1)" = "$expected" ]
    }
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        verify "$dest" || { echo "SHA-256 mismatch: $dest" >&2; exit 1; }
        return 0
    fi
    mkdir -p -- "$(dirname -- "$dest")"
    tmp=$(mktemp "${dest}.download.XXXXXX")
    trap 'rm -f -- "$tmp"' EXIT
    curl --fail --location --proto '=https' --proto-redir '=https' \
        --retry 2 --connect-timeout 30 --output "$tmp" "$url"
    verify "$tmp" || { echo "SHA-256 mismatch: $url" >&2; exit 1; }
    mv -- "$tmp" "$dest"
)
