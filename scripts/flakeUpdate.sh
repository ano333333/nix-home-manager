#!/bin/bash

set -e

echo "update flake"
nix flake update
echo "flake update complete"
