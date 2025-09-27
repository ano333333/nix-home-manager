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
  } @ inputs: {
    homeConfigurations = {
      homeConfiguration = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./.config/home-manager/home.nix
        ];
      };
    };
    
    # home-manager未導入のため、git config --globalできない
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = [ nixpkgs.legacyPackages.x86_64-linux.git ];
      shellHook = ''
        git config --global user.name "ano333333"
        git config --global user.email "ano333333i@gmail.com"
      '';
    };
  };
}