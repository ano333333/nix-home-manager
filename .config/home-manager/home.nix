{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let 
  username = "ano3";
  email = "ano333333github@gmail.com";

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

    packages = [
      pkgs.git
      pkgs.curl
      (import ./packages/asdf.nix { inherit pkgs; })

      # asdf内のpythonビルドが失敗するため、一時3.12をグローバルインストールする
      pkgs.python312
      pkgs.python312Packages.pip
    ];
  };

  programs.home-manager.enable = true;

  programs.git = import ./options/git.nix { inherit email; };

  programs.ssh = {
    enable = true;
  };
  home.activation.generateSshKey = import ./activations/generate-ssh-key.nix { inherit lib config pkgs email; };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # sessionVariablesが何故か効かなかったのでbashrcで指定する
    initExtra = ''
      # add asdf to path
      export ASDF_DATA_DIR="$HOME/.asdf";

      # dir for python simlink
      export PATH="$HOME/.bin:$PATH"

      # docker未インストール時の処理
      if ! dpkg -l | grep -q docker; then
        echo "install docker"
        sudo dpkg -i ${containerd-io} ${docker-ce} ${docker-ce-cli} ${docker-buildx-plugin} ${docker-compose-plugin}
      fi
      # dockerをsystemctl startする
      if ! systemctl status docker; then
        echo "start docker"
        sudo systemctl start docker
      fi
    '';
  };

  # python / pipのシンボリックリンクを作成
  home.file.".bin/python".source = "${pkgs.python312}/bin/python3";
  home.file.".bin/pip".source = "${pkgs.python312Packages.pip}/bin/pip";
}
