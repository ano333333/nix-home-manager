{ pkgs, system, }:
pkgs.stdenv.mkDerivation {
  pname = "asdf-dist";
  version = "0.18.0";
  src = assert system == "x86_64-linux" || system == "aarch64-darwin";
    if system == "x86_64-linux" then
      pkgs.fetchurl {
        url =
          "https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-v0.18.0-linux-amd64.tar.gz";
        sha256 = "sha256-TTAHBwFmywplKvJsPwRisCHgTLJsSrE4lNE2idqJ9bg=";
      }
    else
      pkgs.fetchurl {
        url =
          "https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-v0.18.0-darwin-arm64.tar.gz";
        sha256 = "sha256-XIKvCamxe7cRlc0cCmuqHHxEkbg3rGAcQoU+VTtQphg=";
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
