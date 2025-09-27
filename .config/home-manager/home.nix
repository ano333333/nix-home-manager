{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let 
  username = "ano3";
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

  programs.git = {
    enable = true;
    userName = "ano333333";
    userEmail = "ano333333i@gmail.com";
  };
}