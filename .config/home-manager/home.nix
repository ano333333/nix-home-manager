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

    packages = with pkgs; [
      git
      curl
    ];
  };

  programs.home-manager.enable = true;

  programs.git = import ./options/git.nix;

  programs.ssh = {
    enable = true;
  };
  home.activation.generateSshKey = import ./activations/generate-ssh-key.nix { inherit lib config pkgs email; };
}
