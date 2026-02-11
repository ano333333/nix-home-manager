{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/25.11";
    nixpkgs-claudecode.url =
      "github:NixOS/nixpkgs/d1c2cd5033acedf3f29affd8d44e288107e95238";
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
  };

  outputs = { self, nixpkgs, home-manager, nixgl, nixpkgs-darwin, nix-darwin
    , nixpkgs-claudecode, nixpkgs-yazi, llm-agents, }@inputs:

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
          initDocker = import ./scripts/initDocker.nix { inherit pkgs; };
        in {
          update = {
            type = "app";
            program = "${homeManagerUpdate}/bin/home-manager-update";
          };
          initDocker = {
            type = "app";
            program = "${initDocker}/bin/initDocker";
          };
        });
      homeConfigurationFor = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = system; };
          extraSpecialArgs = {
            inherit inputs;
            system = system;
            pkgs-claudecode = import nixpkgs-claudecode {
              system = system;
              config.allowUnfreePredicate = pkg:
                builtins.elem (nixpkgs-claudecode.lib.getName pkg)
                [ "claude-code" ];
            };
            pkgs-yazi = import nixpkgs-yazi { system = system; };
            llm-agents = llm-agents.packages.${system};
          };
          modules = [ ./.config/home-manager/home.nix ];
        };
    in {
      apps = appsForSystems;

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
