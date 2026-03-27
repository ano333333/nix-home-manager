{ inputs, lib, config, pkgs, system, pkgs-claudecode, pkgs-codex, pkgs-yazi
, llm-agents, ... }:
let
  username = "ano3";
  email = "ano333333github@gmail.com";

  gitignoreAi =
    pkgs.writeText "~/.gitconfig.ai" builtins.readFile ./options/.gitignore.ai;

  neovimPlugins = (import ./packages/neovim-plugins.nix {
    inherit pkgs;
    inherit pkgs-yazi;
  });

  playwrightMcp = (import ./packages/playwright-mcp.nix { inherit pkgs; });

  # pkgをx86_64-linuxの場合のみNixGLでラップする
  wrapNixGLWrapper = pkg:
    (if system == "x86_64-linux" then config.lib.nixGL.wrap pkg else pkg);
in {
  nixpkgs = { config = { allowUnfree = true; }; };

  home = {
    username = username;
    homeDirectory = if system == "x86_64-linux" then
      "/home/${username}"
    else if system == "aarch64-darwin" then
      "/Users/${username}"
    else
      throw "Unsupported system: ${system}";

    stateVersion = "24.05";

    packages = [
      pkgs.git
      pkgs.curl
      (import ./packages/asdf.nix {
        inherit pkgs;
        inherit system;
      })
      pkgs.fzf
      pkgs.ripgrep
      pkgs.deno
      pkgs.lazygit
      pkgs.delta
      (wrapNixGLWrapper pkgs.wezterm)
      pkgs.zoxide
      pkgs.difftastic
      pkgs.typst
      pkgs.tdf

      pkgs.jetbrains.phpstorm
      pkgs.code-cursor
      pkgs-claudecode.claude-code
      pkgs-codex.codex
      pkgs.lsp-ai

      pkgs.lua-language-server
      pkgs.gopls
      pkgs.rust-analyzer
      pkgs.rustfmt
      pkgs.htmx-lsp
      pkgs.typescript-language-server
      pkgs.vtsls
      pkgs.svelte-language-server
      pkgs.nil
      pkgs.nixfmt-classic
      pkgs.tinymist
      pkgs.typstyle

      pkgs.stylua
      pkgs.gofumpt
      pkgs.gotools # for goimports
      pkgs.nodePackages.prettier
      pkgs.biome

      playwrightMcp

      # asdf内のpythonビルドが失敗するため、一時3.12をグローバルインストールする
      pkgs.python312
      pkgs.python312Packages.pip
    ]
    # fonts
      ++ (import ./font.nix { inherit pkgs; })
      # obsidian(mac only)
      ++ (if system == "aarch64-darwin" then [ pkgs.obsidian ] else [ ])
      # alsa-utils for aplay command(ubuntu only)
      ++ (if system == "x86_64-linux" then [ pkgs.alsa-utils ] else [ ])
      # kooha(ubuntu only)
      ++ (if system == "x86_64-linux" then [ pkgs.kooha ] else [ ])
      # llm-agents
      ++ (with llm-agents; [ ccusage opencode ccusage-codex ]);
  };

  fonts = { fontconfig = { enable = true; }; };

  programs.home-manager.enable = true;
  programs.git = import ./options/git.nix { inherit email; };
  home.file.".gitconfig.ai".source = ./options/.gitconfig.ai;

  programs.ssh = { enable = true; };
  home.activation.generateSshKey = import ./activations/generate-ssh-key.nix {
    inherit lib config pkgs email;
  };
  # Obsidian AppImageセットアップ (Linux only)
  home.activation.setupObsidianAppImage = if system == "x86_64-linux" then
    import ./activations/setup-obsidian-appimage.nix {
      inherit lib config pkgs;
    }
  else
    lib.hm.dag.entryAfter [ "writeBoundary" ] "";
  home.activation.setup-rust-analyzer =
    import ./activations/setup-rust-analyzer.nix { inherit lib pkgs; };
  home.activation.setup-skills =
    import ./activations/setup-skills.nix { inherit lib config pkgs; };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables = {
    ZENO_HOME = "${config.xdg.configHome}/zeno";
    TYPST_FONT_PATHS = "${pkgs.noto-fonts-cjk-sans}/share/fonts";
  };
  xdg = {
    enable = true;
    configFile."zeno/config.yml".text =
      builtins.readFile ./options/zsh/zeno.yml;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # sessionVariablesが何故か効かなかったのでzshrcで指定する
    initContent = builtins.readFile ./options/zsh/zshrc;
  };

  programs.starship = import ./options/starship.nix;

  programs.neovim =
    import ./options/neovim/neovim.nix { inherit neovimPlugins; };
  home.file.".config/nvim/lua/lsp.lua".source = ./options/neovim/lua/lsp.lua;
  home.file.".config/nvim/lua/treesitter.lua".source =
    ./options/neovim/lua/treesitter.lua;
  home.file.".config/nvim/lua/conform-config.lua".source =
    ./options/neovim/lua/conform-config.lua;

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

  home.file.".config/wezterm/wezterm.lua".source =
    ./options/wezterm/wezterm.lua;
  home.file.".config/wezterm/keybinds.lua".source =
    ./options/wezterm/keybinds.lua;
  # shell integration
  home.file.".config/wezterm/wezterm.sh".source = ./options/wezterm/wezterm.sh;
  # nekotyan 
  home.file.".config/wezterm/nekotyan/nekotyan.lua".source =
    ./options/wezterm/nekotyan/nekotyan.lua;
  home.file.".config/wezterm/nekotyan/image.png".source =
    ./options/wezterm/nekotyan/image.png;
  home.file.".config/wezterm/nekotyan/image-enter-pressed.png".source =
    ./options/wezterm/nekotyan/image-enter-pressed.png;
  home.file.".config/wezterm/nekotyan/image-headpat-center.png".source =
    ./options/wezterm/nekotyan/image-headpat-center.png;
  home.file.".config/wezterm/nekotyan/image-headpat-left.png".source =
    ./options/wezterm/nekotyan/image-headpat-left.png;
  home.file.".config/wezterm/nekotyan/image-headpat-right.png".source =
    ./options/wezterm/nekotyan/image-headpat-right.png;
  home.file.".config/wezterm/nekotyan/image-headpat-finished-1.png".source =
    ./options/wezterm/nekotyan/image-headpat-finished-1.png;
  home.file.".config/wezterm/nekotyan/image-headpat-finished-2.png".source =
    ./options/wezterm/nekotyan/image-headpat-finished-2.png;
  # cheatsheet
  home.file.".config/wezterm/cheatsheet.lua".source =
    ./options/wezterm/cheatsheet.lua;

  # yazi
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    initLua = ./options/yazi/init.lua;
    keymap = {
      mgr.prepend_keymap = [
        {
          on = [ "<C-c>" ];
          run = "escape --all";
        }
        {
          on = [ "<F2>" ];
          run = "rename";
        }
        {
          on = [ "<S-4>" ];
          run = "copy path";
        }
        {
          on = [ "<C-f>" ];
          run = "find --smart";
        }
        {
          on = [ "<C-d>" ];
          run = "plugin diff";
        }
        {
          on = [ "g" "i" ];
          run = "plugin lazygit";
        }
      ];
    };
    package = pkgs-yazi.yazi;
    plugins = with pkgs-yazi.yaziPlugins; {
      git = git;
      diff = diff;
      lazygit = lazygit;
    };
  };
  home.file.".config/yazi/yazi.toml".source = ./options/yazi/yazi.toml;

  # ghostty config
  home.file.".config/ghostty/config".source = ./options/ghostty;

  # python / pipのシンボリックリンクを作成
  home.file.".bin/python".source = "${pkgs.python312}/bin/python3";
  home.file.".bin/pip".source = "${pkgs.python312Packages.pip}/bin/pip";
}
