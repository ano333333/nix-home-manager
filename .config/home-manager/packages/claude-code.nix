# nixpkgs の pkgs/by-name/cl/claude-code/package.nix を参考にした、
# 公式配布バイナリからの claude-code ビルド。
#
# バージョン更新手順:
# ```sh
# VERSION=$(curl -fsSL https://downloads.claude.ai/claude-code-releases/latest)
# curl -fsSL "https://downloads.claude.ai/claude-code-releases/$VERSION/manifest.json" \
#   -o .config/home-manager/packages/claude-code-manifest.json
# ```
{ pkgs, manifest ? pkgs.lib.importJSON ./claude-code-manifest.json }:
let
  inherit (pkgs) lib stdenvNoCC;
  stdenv = stdenvNoCC;
  baseUrl = "https://downloads.claude.ai/claude-code-releases";
  platformKey =
    "${stdenv.hostPlatform.node.platform}-${stdenv.hostPlatform.node.arch}";
  platformManifestEntry = manifest.platforms.${platformKey};
in stdenv.mkDerivation (finalAttrs: {
  pname = "claude-code";
  inherit (manifest) version;

  src = pkgs.fetchurl {
    url = "${baseUrl}/${finalAttrs.version}/${platformKey}/claude";
    sha256 = platformManifestEntry.checksum;
  };

  dontUnpack = true;
  dontBuild = true;
  __noChroot = stdenv.hostPlatform.isDarwin;
  # これを外すとバイナリではなく bun ランタイムが実行されてしまう
  dontStrip = true;

  nativeBuildInputs = with pkgs;
    [ installShellFiles makeBinaryWrapper ]
    ++ lib.optionals stdenv.hostPlatform.isElf [ autoPatchelfHook ];

  strictDeps = true;

  installPhase = ''
    runHook preInstall

    installBin $src

    wrapProgram $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1 \
      --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
      --set DISABLE_INSTALLATION_CHECKS 1 \
      --set USE_BUILTIN_RIPGREP 0 \
      ${
        lib.optionalString stdenv.hostPlatform.isLinux ''
          --prefix LD_LIBRARY_PATH : ${
            lib.makeLibraryPath [ pkgs.alsa-lib ]
          } \
        ''
      }--prefix PATH : ${
        lib.makeBinPath ([
          # claude-code は node-tree-kill を使うため procps の pgrep/ps が必要
          pkgs.procps
          # https://code.claude.com/docs/en/troubleshooting#search-and-discovery-issues
          pkgs.ripgrep
        ]
        # sandbox 機能に必要（Linux のみ）
        ++ lib.optionals stdenv.hostPlatform.isLinux [
          pkgs.bubblewrap
          pkgs.socat
        ])
      }

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = with pkgs; [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "--version";

  meta = {
    description =
      "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
    homepage = "https://github.com/anthropics/claude-code";
    downloadPage = "https://claude.com/product/claude-code";
    changelog =
      "https://github.com/anthropics/claude-code/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms =
      [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
    mainProgram = "claude";
  };
})
