{ pkgs }:
let dcomp = import ./csp-dcomp { inherit pkgs; };
in pkgs.writeShellApplication {
  name = "csp4";
  runtimeInputs = with pkgs; [
    wineWowPackages.stable
    winetricks
    coreutils
    findutils
    curl
    gnused
    procps
  ];
  text = ''
    export CSP_DCOMP_DLL=${dcomp}/lib/dcomp.dll
  '' + builtins.readFile ./csp4.sh;
}
