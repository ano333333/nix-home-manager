{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # unstableから最新のclaudecode, codex, typstを取得
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # for yazi version 26.1.4
    nixpkgs-yazi.url =
      "github:NixOS/nixpkgs/a56cd57f820aff743ba6aaa7894f88ed77f085a9";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = { url = "github:nix-community/nixGL"; };
    # バージョン指定のnixpkgsをnix-darwinと併用する場合はnixpkgs-xx.xx-darwinブランチが必要
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    skills = {
      url = "github:ano333333/skills";
      flake = false;
    };
    piExtensions = {
      url = "github:ano333333/pi-extensions";
      flake = false;
    };
    zeno = {
      url = "github:yuki-yano/zeno.zsh";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, nixgl, nixpkgs-darwin, nix-darwin
    , nixpkgs-unstable, nixpkgs-yazi, llm-agents, hyprland, hyprland-plugins
    , hunk, herdr, skills, piExtensions, zeno, }@inputs:

    let
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      appsForSystems = nixpkgs.lib.genAttrs systems (system:
        let
          # nix-darwinと併用するか否かでnixpkgsのブランチを分ける
          pkgs = if builtins.match "^.*-darwin" system != null then
            import nixpkgs-darwin { inherit system; }
          else
            import nixpkgs { inherit system; };
          # updateコマンドに指定するために、homeManagerUpdate.shをnixストアにコピー
          homeManagerUpdate = pkgs.writeShellApplication {
            name = "home-manager-update";
            runtimeInputs = [ pkgs.nix ];
            text = pkgs.lib.readFile ./scripts/homeManagerUpdate.sh;
          };
          # updateFlakeコマンドに指定するために、flakeUpdate.shをnixストアにコピー
          flakeUpdate = pkgs.writeShellApplication {
            name = "flake-update";
            runtimeInputs = [ pkgs.nix ];
            text = pkgs.lib.readFile ./scripts/flakeUpdate.sh;
          };
          initDocker = import ./scripts/initDocker.nix { inherit pkgs; };
        in {
          update = {
            type = "app";
            program = "${homeManagerUpdate}/bin/home-manager-update";
          };
          updateFlake = {
            type = "app";
            program = "${flakeUpdate}/bin/flake-update";
          };
          initDocker = {
            type = "app";
            program = "${initDocker}/bin/initDocker";
          };
        });
      extraSpecialArgs = system: {
        inherit inputs;
        inherit skills;
        inherit piExtensions;
        inherit zeno;
        system = system;
        pkgs-unstable = let
          unstablePkgs = import nixpkgs-unstable {
            system = system;
            config.allowUnfreePredicate = pkg:
              builtins.elem (nixpkgs-unstable.lib.getName pkg) [
                "claude-code"
                "codex"
              ];
          };
        in {
          claude-code = unstablePkgs.claude-code;
          codex = unstablePkgs.codex;
          typst = unstablePkgs.typst;
        };
        pkgs-yazi = let yaziPkgs = import nixpkgs-yazi { system = system; };
        in {
          yazi = yaziPkgs.yazi;
          yaziPlugins = yaziPkgs.yaziPlugins;
          vimPlugins.yazi-nvim = yaziPkgs.vimPlugins.yazi-nvim;
        };
        llm-agents = llm-agents.packages.${system};
        hyprland = hyprland.packages.${system};
        hyprland-plugins = hyprland-plugins.packages.${system};
      };
      homeConfigurationFor = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = system; };
          extraSpecialArgs = extraSpecialArgs system;
          modules = [ ./.config/home-manager/home.nix ];
        };
    in {
      apps = appsForSystems;

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.default
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.ano3 = ./.config/home-manager/home.nix;
              extraSpecialArgs = extraSpecialArgs "x86_64-linux";
            };
          }
        ];
        specialArgs = { inherit inputs skills; };
      };

      homeConfigurations = {
        linux = homeConfigurationFor "x86_64-linux";
        darwin = homeConfigurationFor "aarch64-darwin";
      };

      darwinConfigurations.darwin = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./.config/nix-darwin/default.nix ];
      };
    };
}
