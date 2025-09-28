{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let 
  username = "ano3";
  email = "ano333333github@gmail.com";
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

      # asdf内のpythonビルドが失敗するため、一時3.12をグローバルインストールする
      pkgs.python312
      pkgs.python312Packages.pip
    ];
  };

  programs.home-manager.enable = true;

  programs.git = import ./options/git.nix { inherit email; };

  programs.ssh = {
    enable = true;
  };
  home.activation.generateSshKey = import ./activations/generate-ssh-key.nix { inherit lib config pkgs email; };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # sessionVariablesが何故か効かなかったのでbashrcで指定する
    initExtra = ''
      # add asdf to path
      export ASDF_DATA_DIR="$HOME/.asdf";

      # dir for python simlink
      export PATH="$HOME/.bin:$PATH"
    '';
  };

  # python / pipのシンボリックリンクを作成
  home.file.".bin/python".source = "${pkgs.python312}/bin/python3";
  home.file.".bin/pip".source = "${pkgs.python312Packages.pip}/bin/pip";
}
