{ zeno, ... }: ''
  # dir for python simlink
  export PATH="$HOME/.bin:$PATH"
  # add asdf to path
  export ASDF_DATA_DIR="$HOME/.asdf";
  export PATH="$ASDF_DATA_DIR/shims:$PATH"

  # zeno is pinned by flake.lock. Copy it out of the Nix store because Deno
  # creates node_modules next to the source when zeno starts.
  export ZENO_HOME="''${TMPDIR:-/tmp}/zeno-''${USER}"
  export ZENO_ROOT="$ZENO_HOME/${builtins.baseNameOf zeno}"
  mkdir -p "$ZENO_HOME"
  ln -sfn "$HOME/.config/zeno/config.yml" "$ZENO_HOME/config.yml"
  if [[ ! -f "$ZENO_ROOT/zeno.zsh" ]]; then
    cp -R ${zeno} "$ZENO_ROOT"
    chmod -R u+w "$ZENO_ROOT"
  fi
  source "$ZENO_ROOT/zeno.zsh"

  # ########################################
  # zeno
  # ########################################
  # git file preview with color
  export ZENO_GIT_CAT="bat --color=always"

  # git folder preview with color
  export ZENO_GIT_TREE="eza --tree"

  # Register zeno widgets before heavy init completes.
  zeno-bind-default-keys --lazy

  # wezterm shell integration
  source "$HOME/.config/wezterm/wezterm.sh"

  # enable zoxide
  eval "$(zoxide init zsh)"
''
