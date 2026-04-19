#!/bin/bash

set -e

os=$(uname -s)

echo "current OS: $os"

echo "update home-manager"
if [ "$os" = "Linux" ]; then
  if uname -v | grep -q "NixOS"; then
    sudo nixos-rebuild switch --flake .
  else
    nix run nixpkgs#home-manager -- switch --flake .#linux
  fi
elif [ "$os" = "Darwin" ]; then
  nix run nixpkgs#home-manager -- switch --flake .#darwin
  sudo nix run nix-darwin -- switch --flake .#darwin
fi

echo "home-manager update complete"
