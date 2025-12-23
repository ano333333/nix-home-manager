{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
    };
    # バージョン指定のnixpkgsをnix-darwinと併用する場合はnixpkgs-xx.xx-darwinブランチが必要
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixgl,
    nixpkgs-darwin,
    nix-darwin,
  } @ inputs: 
  
  let
    systems = [ "x86_64-linux" "aarch64-darwin" ];
    appsForSystems = nixpkgs.lib.genAttrs systems (
      system:
      let
        # nix-darwinと併用するか否かでnixpkgsのブランチを分ける
        pkgs =
          if builtins.match "^.*-darwin"
          then import nixpkgs-darwin { inherit system; }
          else import nixpkgs { inherit system; };
        # updateコマンドに指定するために、homeManagerUpdate.shをnixストアにコピー
        homeManagerUpdate = pkgs.writeShellApplication {
          name = "home-manager-update";
          runtimeInputs = [ pkgs.nix ];
          text = pkgs.lib.readFile ./scripts/homeManagerUpdate.sh;
        };
        initDocker = import ./scripts/initDocker.nix { inherit pkgs; };
      in
      {
        update = {
          type = "app";
          program = "${homeManagerUpdate}/bin/home-manager-update";
        };
        initDocker = {
          type = "app";
          program = "${initDocker}/bin/initDocker";
        };
      }
    );
    homeConfigurationFor = system: home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = system; };
      extraSpecialArgs = {
        inherit inputs;
        system = system;
      };
      modules = [
        ./.config/home-manager/home.nix
      ];
    };
  in
  {
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
