{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: {
    packages.x86_64-linux.profiles = nixpkgs.legacyPackages.x86_64-linux.buildEnv {
      name = "profiles";
      paths = [
        nixpkgs.legacyPackages.x86_64-linux.git
        nixpkgs.legacyPackages.x86_64-linux.curl
      ];
    };
  };
}