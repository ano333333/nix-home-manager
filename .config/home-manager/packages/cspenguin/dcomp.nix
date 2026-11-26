{ pkgs }:
let cross = pkgs.pkgsCross.mingwW64;
in cross.stdenv.mkDerivation {
  pname = "cspenguin-dcomp";
  version = "868d022";
  src = ./upstream/patches/dcomp;
  dontConfigure = true;
  dontStrip = true;
  buildPhase = ''
    $CXX -shared -static -O2 -std=c++17 -o dcomp-built.dll dcomp_csp.cpp dcomp.def \
      -lole32 -lgdi32 -ldxgi -ld3d11 -luuid
    $OBJDUMP -p dcomp-built.dll > imports.txt
    if grep -Ei 'DLL Name:.*(libgcc|libstdc|libwinpthread)' imports.txt; then
      echo "Unexpected dynamic compiler runtime dependency" >&2
      exit 1
    fi
  '';
  installPhase = ''
    mkdir -p $out/lib $out/share/cspenguin
    cp dcomp-built.dll $out/lib/dcomp.dll
    cp imports.txt $out/share/cspenguin/
  '';
}
