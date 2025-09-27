{
  pkgs,
}:
pkgs.stdenv.mkDerivation {
  pname = "asdf-dist";
  version = "0.18.0";
  src = pkgs.fetchurl {
    url = "https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-v0.18.0-linux-amd64.tar.gz";
    sha256 = "sha256-TTAHBwFmywplKvJsPwRisCHgTLJsSrE4lNE2idqJ9bg=";
  };
  nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ];
  phases = [ "unpackPhase" "installPhase" ];
  unpackPhase = ''
    mkdir src
    tar -xzf "$src" -C src
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp src/asdf $out/bin/asdf
  '';
}
