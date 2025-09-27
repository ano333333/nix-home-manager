{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
  } @ inputs: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { system = system; };
    # updateコマンドに指定するために、homeManagerUpdate.shをnixストアにコピー
    homeManagerUpdate = pkgs.writeShellApplication {
      name = "home-manager-update";
      runtimeInputs = [ pkgs.nix ];
      text = pkgs.lib.readFile ./scripts/homeManagerUpdate.sh;
    };
  in
  {
    apps.${system}.update= {
      type = "app";
      program = "${homeManagerUpdate}/bin/home-manager-update";
    };

    homeConfigurations = {
      homeConfiguration = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./.config/home-manager/home.nix
        ];
      };
    };
  };
}
