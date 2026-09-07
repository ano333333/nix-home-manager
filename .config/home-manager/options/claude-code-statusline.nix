{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "claude-code-statusline";

  runtimeInputs = [ pkgs.jq ];

  text = ''
    #!/usr/bin/env bash
    # Claude Code status line
    # - current directory (Starship-like, e.g. home shortened to ~)
    # - current git branch (only inside a git repo)
    # - context usage percentage (from status line JSON input)

    input=$(cat)

    cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
    [ -z "$cwd" ] && cwd="$PWD"

    # Shorten $HOME to ~ (Starship-like directory display)
    dir="''${cwd/#$HOME/\~}"

    # Git branch (skip optional locks, only show if inside a git repo)
    branch=""
    if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
      if [ -z "$branch" ]; then
        branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
      fi
    fi

    # Context usage percentage (pre-calculated field from status line input)
    used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

    # Colors (dimmed, suitable for terminal status line)
    COLOR_DIR="\033[2;34m"   # dim blue
    COLOR_GIT="\033[2;32m"   # dim green
    COLOR_CTX="\033[2;33m"   # dim yellow
    COLOR_RESET="\033[0m"

    parts=()
    parts+=("$(printf "''${COLOR_DIR}%s''${COLOR_RESET}" "$dir")")

    if [ -n "$branch" ]; then
      parts+=("$(printf "''${COLOR_GIT}(%s)''${COLOR_RESET}" "$branch")")
    fi

    if [ -n "$used" ]; then
      pct=$(echo "$used" | cut -d. -f1)
      parts+=("$(printf "''${COLOR_CTX}ctx:%s%%''${COLOR_RESET}" "$pct")")
    fi

    IFS=' '
    printf "%s\n" "''${parts[*]}"
  '';
}
