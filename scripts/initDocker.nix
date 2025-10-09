{
  pkgs,
}:
let
  containerd-io = pkgs.fetchurl {
    url = "https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/containerd.io_1.7.28-0~ubuntu.24.04~noble_amd64.deb";
    sha256 = "sha256-4d3Trna1ZDzrrYqcdrgsxf09r07HbsHfde2swv4xO7U=";
  };
  docker-ce = pkgs.fetchurl {
    url = "https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/docker-ce_28.5.1-1~ubuntu.24.04~noble_amd64.deb";
    sha256 = "sha256-tS0hCTyHxt1MT8ZUhFPnGrPdd1YKcHODPCeX3ijoi4M=";
  };
  docker-ce-cli = pkgs.fetchurl {
    url = "https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/docker-ce-cli_28.5.1-1~ubuntu.24.04~noble_amd64.deb";
    sha256 = "sha256-fOaCaj06P/xYsgnBaBlF6JqKHqmyc2CY0cWq1tOf3/Y=";
  };
  docker-buildx-plugin = pkgs.fetchurl {
    url = "https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/docker-buildx-plugin_0.29.1-1~ubuntu.24.04~noble_amd64.deb";
    sha256 = "sha256-yj3XjBoAmNPyNvMO9NDf9NffIixfsXliZBUDRRq8hCk=";
  };
  docker-compose-plugin = pkgs.fetchurl {
    url = "https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/docker-compose-plugin_2.40.0-1~ubuntu.24.04~noble_amd64.deb";
    sha256 = "sha256-udgXEJsyWfSho6RujCqU1FgVCFUXVs7byap7XBcbWJE=";
  };
in
  pkgs.writeShellScriptBin "initDocker" ''
    set -euo pipefail

    # dockerが未インストールならばインストールする
    if ! dpkg -l | grep -q docker; then
      echo "install docker"
      sudo dpkg -i ${containerd-io} ${docker-ce} ${docker-ce-cli} ${docker-buildx-plugin} ${docker-compose-plugin}
    fi

    # dockerをsystemctl startする
    if ! systemctl status docker; then
      echo "start docker"
       systemctl start docker
    fi

    # ユーザーをdockerグループに追加する
    if ! id -nG "$USER" | grep -qw docker; then
      echo "add user $USER to docker group"
      sudo usermod -aG docker "$USER"
      newgrp docker
    fi
  ''