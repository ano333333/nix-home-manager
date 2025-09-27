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
    ];
  };

  programs.home-manager.enable = true;

  programs.git = import ./options/git.nix;

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
    '';
  };
}
