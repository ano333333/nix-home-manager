{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
  } @ inputs: 
  
  let
    systems = [ "x86_64-linux" "aarch64-darwin" ];
    appsForSystems = nixpkgs.lib.genAttrs systems (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
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
