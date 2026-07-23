{ zeno, ... }: ''
  # dir for python simlink
  export PATH="$HOME/.bin:$PATH"
  # add asdf to path
  export ASDF_DATA_DIR="$HOME/.asdf";
  export PATH="$ASDF_DATA_DIR/shims:$PATH"

  # zeno is pinned by flake.lock.
  source ${zeno}/zeno.zsh

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
