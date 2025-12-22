{
  inputs,
  lib,
  config,
  pkgs,
  system,
  ...
}: let 
  username = "ano3";
  email = "ano333333github@gmail.com";

  gitignoreAi = pkgs.writeText "~/.gitconfig.ai" builtins.readFile ./options/.gitignore.ai;

  neovimPlugins = (import ./packages/neovim-plugins.nix { inherit pkgs; });

  # pkgをx86_64-linuxの場合のみNixGLでラップする
  wrapNixGLWrapper = pkg: (
    if system == "x86_64-linux"
    then config.lib.nixGL.wrap pkg
    else pkg
  );
in {
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = username;
    homeDirectory = if system == "x86_64-linux" then "/home/${username}"
                    else if system == "aarch64-darwin" then "/Users/${username}"
                    else throw "Unsupported system: ${system}";

    stateVersion = "24.05";

    packages = [
      pkgs.git
      pkgs.curl
      (import ./packages/asdf.nix { inherit pkgs; })
      pkgs.fzf
      pkgs.deno
      pkgs.lazygit
      pkgs.delta
      (wrapNixGLWrapper pkgs.wezterm)
      
      pkgs.jetbrains.phpstorm
      pkgs.code-cursor
      pkgs.claude-code

      # asdf内のpythonビルドが失敗するため、一時3.12をグローバルインストールする
      pkgs.python312
      pkgs.python312Packages.pip
    ]
    # fonts
    ++ (import ./font.nix { inherit pkgs; })
    # obsidian(mac only)
    ++ (if system == "aarch64-darwin" then [ pkgs.obsidian ] else [])
    ;
  };

  fonts = {
    fontconfig = {
      enable = true;
    };
  };

  programs.home-manager.enable = true;
  programs.git = import ./options/git.nix { inherit email; };
  home.file.".gitconfig.ai".source = ./options/.gitignore.ai;

  programs.ssh = {
    enable = true;
  };
  home.activation.generateSshKey = import ./activations/generate-ssh-key.nix { inherit lib config pkgs email; };
  # Obsidian AppImageセットアップ (Linux only)
  home.activation.setupObsidianAppImage = if system == "x86_64-linux"
    then import ./activations/setup-obsidian-appimage.nix { inherit lib config pkgs; }
    else lib.hm.dag.entryAfter [ "writeBoundary" ] "";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables = {
    ZENO_HOME = "${config.xdg.configHome}/zeno";
  };
  xdg = {
    enable = true;
    configFile."zeno/config.yml".text = builtins.readFile ./options/zsh/zeno.yml;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # sessionVariablesが何故か効かなかったのでzshrcで指定する
    initContent = builtins.readFile ./options/zsh/zshrc;
  };

  programs.starship = import ./options/starship.nix;

  programs.neovim = import ./options/neovim.nix { inherit neovimPlugins; };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # claude-code config
  home.file.".claude/settings.json".source = ./options/claude-code.json;

  # nixGL(Linux on amd64 only)
  nixGL = lib.mkIf (system == "x86_64-linux") {
    packages = import inputs.nixgl { inherit pkgs; };
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
  };

  home.file.".config/wezterm/wezterm.lua".source = ./options/wezterm/wezterm.lua;
  home.file.".config/wezterm/keybinds.lua".source = ./options/wezterm/keybinds.lua;
  home.file.".config/wezterm/image.png".source = ./options/wezterm/image.png;
  home.file.".config/wezterm/image-enter-pressed.png".source = ./options/wezterm/image-enter-pressed.png;

  # ghostty config
  home.file.".config/ghostty/config".source = ./options/ghostty;

  # python / pipのシンボリックリンクを作成
  home.file.".bin/python".source = "${pkgs.python312}/bin/python3";
  home.file.".bin/pip".source = "${pkgs.python312Packages.pip}/bin/pip";
}
