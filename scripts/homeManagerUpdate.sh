# !/bin/bash

set -e

echo "update flake"
nix flake update

echo "update home-manager"
nix run nixpkgs#home-manager -- switch --flake .#homeConfiguration

echo "update complete"
