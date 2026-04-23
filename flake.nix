{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/25.11";
    nixpkgs-claudecode.url =
      "github:NixOS/nixpkgs/d1c2cd5033acedf3f29affd8d44e288107e95238";
    nixpkgs-codex.url =
      "github:NixOS/nixpkgs/ffe93a687100a860bba45878169aee8aa2d8edcf";
    # for typst.withPackages
    nixpkgs-typst.url =
      "github:NixOS/nixpkgs/ffe93a687100a860bba45878169aee8aa2d8edcf";
    # for yazi version 26.1.4
    nixpkgs-yazi.url =
      "github:NixOS/nixpkgs/a56cd57f820aff743ba6aaa7894f88ed77f085a9";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = { url = "github:nix-community/nixGL"; };
    # バージョン指定のnixpkgsをnix-darwinと併用する場合はnixpkgs-xx.xx-darwinブランチが必要
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    skills = {
      url = "github:ano333333/skills";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, nixgl, nixpkgs-darwin, nix-darwin
    , nixpkgs-claudecode, nixpkgs-codex, nixpkgs-typst, nixpkgs-yazi, llm-agents
    , hyprland, hyprland-plugins, skills, }@inputs:

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
        system = system;
        pkgs-claudecode = import nixpkgs-claudecode {
          system = system;
          config.allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs-claudecode.lib.getName pkg)
            [ "claude-code" ];
        };
        pkgs-codex = import nixpkgs-codex {
          system = system;
          config.allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs-codex.lib.getName pkg) [ "codex" ];
        };
        pkgs-typst = import nixpkgs-typst { system = system; };
        pkgs-yazi = import nixpkgs-yazi { system = system; };
        llm-agents = llm-agents.packages.${system};
        hyprland = hyprland.packages.${system};
        hyprland-plugins = hyprland-plugins.packages.${system};
      };
      homeConfigurationFor = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = system; };
          extraSpecialArgs = extraSpecialArgs { system = system; };
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
        specialArgs = { inherit inputs; };
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
