{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let 
  username = "ano3";
  email = "ano333333github@gmail.com";

  gitignoreAi = pkgs.writeText "~/.gitconfig.ai" builtins.readFile ./options/.gitignore.ai;

  vimPlugins = (import ./packages/vim-plugins.nix { inherit pkgs; });
in {
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = username;
    homeDirectory = "/home/${username}";

    stateVersion = "24.05";

    packages = [
      pkgs.git
      pkgs.curl
      (import ./packages/asdf.nix { inherit pkgs; })
      pkgs.fzf
      pkgs.zsh-abbr

      # asdf内のpythonビルドが失敗するため、一時3.12をグローバルインストールする
      pkgs.python312
      pkgs.python312Packages.pip
    ]
    # fonts
    ++ (import ./font.nix { inherit pkgs; })
    ;
  };

  fonts = {
    fontconfig = {
      enable = true;
    };
  };

  programs.home-manager.enable = true;

  programs.git = import ./options/git.nix { inherit email; };
  home.file.".gitconfig.ai".source = ./options/.gitignore.ai;

  programs.ssh = {
    enable = true;
  };
  home.activation.generateSshKey = import ./activations/generate-ssh-key.nix { inherit lib config pkgs email; };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    zsh-abbr = import ./options/zsh/zsh-abbr.nix;
    # sessionVariablesが何故か効かなかったのでzshrcで指定する
    initContent = ''
      # add asdf to path
      export ASDF_DATA_DIR="$HOME/.asdf";

      # dir for python simlink
      export PATH="$HOME/.bin:$PATH"

      # zsh-abbr
      # カーソルの位置を"%"に移動する
      ABBR_SET_LINE_CURSOR=1

      # install zinit
      ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"
      [ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
      [ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
      source "$ZINIT_HOME/zinit.zsh"
    '';
  };

  programs.starship = import ./options/starship.nix;

  programs.vim = import ./options/vim.nix { inherit vimPlugins; };

  # python / pipのシンボリックリンクを作成
  home.file.".bin/python".source = "${pkgs.python312}/bin/python3";
  home.file.".bin/pip".source = "${pkgs.python312Packages.pip}/bin/pip";
}
