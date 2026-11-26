{ pkgs }:
let cross = pkgs.pkgsCross.mingwW64;
in cross.stdenv.mkDerivation {
  pname = "csp-dcomp";
  version = "868d022";
  src = ./.;
  dontConfigure = true;
  dontStrip = true;
  buildPhase = ''
    $CXX -shared -static -O2 -std=c++17 -o dcomp.dll dcomp_csp.cpp dcomp.def \
      -lole32 -lgdi32 -ldxgi -ld3d11 -luuid
    $OBJDUMP -p dcomp.dll > imports.txt
    # The compiler runtimes must be linked into the DLL, not downloaded binaries.
    if grep -Ei 'DLL Name:.*(libgcc|libstdc|libwinpthread)' imports.txt; then
      echo "Unexpected dynamic compiler runtime dependency" >&2
      exit 1
    fi
  '';
  installPhase = ''
    mkdir -p $out/lib $out/share/csp-dcomp
    cp dcomp.dll $out/lib/
    cp imports.txt $out/share/csp-dcomp/
  '';
}
