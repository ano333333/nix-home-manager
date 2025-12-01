# TILリポジトリを~/private/TILにcloneする
{
  lib,
  config,
  pkgs,
  ...
}: lib.hm.dag.entryAfter [ "generateSshKey" ] ''
  set -eu

  PRIVATE_DIR="${config.home.homeDirectory}/private"
  TIL_DIR="$PRIVATE_DIR/TIL"

  # privateディレクトリがなければ作成
  if [ ! -d "$PRIVATE_DIR" ]; then
    echo "Creating $PRIVATE_DIR directory..."
    mkdir -p "$PRIVATE_DIR"
  fi

  # TILリポジトリがなければclone
  if [ ! -d "$TIL_DIR" ]; then
    echo "Cloning TIL repository to $TIL_DIR..."
    ${pkgs.git}/bin/git clone git@github.com:kikuchi-masahide/TIL.git "$TIL_DIR"
    echo "TIL repository cloned successfully"
  else
    echo "TIL repository already exists at $TIL_DIR"
  fi
''
