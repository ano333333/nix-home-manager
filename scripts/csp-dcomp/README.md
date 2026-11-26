# CSP DirectComposition shim

Upstream: https://github.com/parka6060/CSPenguin-Installer

Revision: `868d022adfdc3740449241f4721debbf4b1b1426`

`dcomp_csp.cpp` and `dcomp.def` are copied from `patches/dcomp/` at this revision.
The upstream prebuilt DLLs and installer are not used. `default.nix` builds a
64-bit Windows DLL with Nixpkgs' MinGW toolchain. Compiler runtimes are linked
statically; the build checks there is no libgcc/libstdc++/libwinpthread DLL import.

Source review: no network or credential-handling code found. It hooks DXGI COM
vtables using VirtualProtect and a deferred thread; compatibility crashes/races
remain possible. It implements only a subset of DirectComposition and reads back
textures to GDI. It appends diagnostic metadata to `C:\dcomp-csp.log` without rotation.
This review is not a security audit or a guarantee of stability.

The shim is installed only in the CSP Wine prefix, with the previous DLL and
`dcomp` override saved under `csp-dcomp-backup`. Close CSP/WebView2 before setup or
restore. `csp4 restore-dcomp` restores those saved values, leaving the backup intact.
