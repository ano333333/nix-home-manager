# rust-analyzerのセットアップを行う
{ lib, pkgs, }:
lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  set -eu

  # Rust 1.91.1を設定
  ${pkgs.rustup}/bin/rustup default 1.91.1

  # rust-srcがインストール済みかチェック
  if ! ${pkgs.rustup}/bin/rustup component list --installed | grep -q "^rust-src"; then
    echo "Installing rust-src..."
    ${pkgs.rustup}/bin/rustup component add rust-src
  else
    echo "rust-src is already installed, skipping."
  fi
''

