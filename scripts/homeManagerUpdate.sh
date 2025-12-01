#!/bin/bash

set -e

os=$(uname -s)

echo "current OS: $os"

echo "update flake"
nix flake update

echo "update home-manager"
if [ "$os" = "Linux" ]; then
  nix run nixpkgs#home-manager -- switch --flake .#linux
elif [ "$os" = "Darwin" ]; then
  nix run nixpkgs#home-manager -- switch --flake .#darwin
  sudo nix run nix-darwin -- switch --flake .#darwin
fi

echo "update complete"
