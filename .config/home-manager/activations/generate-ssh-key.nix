# ssh-keygenをactivationで実行する
{
  lib,
  config,
  pkgs,
  email,
}: lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  set -eu

  SSH_DIR="${config.home.homeDirectory}/.ssh"
  PRIV_KEY_ED25519_PATH="$SSH_DIR/id_ed25519"
  PUB_KEY_ED25519_PATH="$SSH_DIR/id_ed25519.pub"
  PRIV_KEY_ED25519_2_PATH="$SSH_DIR/id_ed25519_2"
  PUB_KEY_ED25519_2_PATH="$SSH_DIR/id_ed25519_2.pub"

  if [ ! -f "$PRIV_KEY_ED25519_PATH" ]; then
    echo "Generating SSH key(ed25519)..."
    ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "${email}" -f "$PRIV_KEY_ED25519_PATH" -N ""
    echo "SSH key(ed25519) generated successfully"
  else
    echo "SSH key(ed25519) already exists"
  fi

  if [ ! -f "$PRIV_KEY_ED25519_2_PATH" ]; then
    echo "Generating SSH key(ed25519) 2..."
    ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "${email}" -f "$PRIV_KEY_ED25519_2_PATH" -N ""
    echo "SSH key(ed25519) 2 generated successfully"
  else
    echo "SSH key(ed25519) 2 already exists"
  fi
''
