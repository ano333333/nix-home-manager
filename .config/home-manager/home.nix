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
  };

  programs.home-manager.enable = true;
}