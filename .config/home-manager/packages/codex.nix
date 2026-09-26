# nixpkgs の pkgs/by-name/co/codex/package.nix を参考にした codex のビルド。
# nixpkgs 側で別ファイルになっている librusty_v8.nix / fetchers.nix は
# このファイルに統合している。
#
# バージョン更新手順:
# 1. https://github.com/openai/codex/releases で最新の rust-vX.Y.Z を確認し version を更新
# 2. `nix flake prefetch --json github:openai/codex/rust-vX.Y.Z` で src の hash を更新
# 3. codex-rs/Cargo.lock の `v8` crate のバージョンを librustyV8.version に反映し、
#    下記 2 種の URL の各ターゲットを `nix store prefetch-file` して shas を更新
#    https://github.com/denoland/rusty_v8/releases/download/v<version>/librusty_v8_release_<rustcTarget>.a.gz
#    https://github.com/denoland/rusty_v8/releases/download/v<version>/src_binding_release_<rustcTarget>.rs
# 4. cargoHash は lib.fakeHash に置き換えてビルドし、エラーに出る正しい値へ更新
#
# rustPlatform は呼び出し側から差し替えられるようにしている。nixpkgs 25.11 の
# rustc 1.91 では依存の sqlx 0.9 が要求する rustc 1.94 を満たせないため、
# home.nix からは nixpkgs-unstable の rustPlatform を渡している。
{ pkgs, rustPlatform ? pkgs.rustPlatform }:
let
  inherit (pkgs) lib stdenv;

  # nixpkgs の fetchers.nix / librusty_v8.nix / librusty_v8_src_binding.nix 相当。
  # codex-rs/Cargo.lock の v8 crate と同じバージョンを指定する。
  librustyV8Version = "150.4.0";

  # prebuilt の静的ライブラリ。
  librustyV8 = let
    shas = {
      x86_64-linux = "sha256-WGn9twcbHyHyAKl86X0gElh34PMc2ALtmd4sU/SIsGw=";
      aarch64-linux = "sha256-txd9Uq0zNycv4NO453gjnIIalcJdWVnexiue/WVPfdM=";
      x86_64-darwin = "sha256-5ex9E/kUgT6/IB1Ee/j9J2h7exkuFsR/KCb+VBUXHyk=";
      aarch64-darwin = "sha256-zNj4FIW4IsWxiuun+d65KaM4LYasZzu/DzZvBod+axA=";
    };
  in pkgs.fetchurl {
    name = "librusty_v8-${librustyV8Version}";
    url =
      "https://github.com/denoland/rusty_v8/releases/download/v${librustyV8Version}/librusty_v8_release_${stdenv.hostPlatform.rust.rustcTarget}.a.gz";
    hash = shas.${stdenv.hostPlatform.system};
    meta = {
      version = librustyV8Version;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  };

  # 生成済みの bindgen バインディング。
  # codex は v8 の v8_enable_sandbox feature を有効にするため、v8 の build.rs は
  # 既定では `src_binding_ptrcomp_sandbox_release_<target>.rs` を探しに行くが、
  # rusty_v8 のリリースにその名前の成果物は存在しない。RUSTY_V8_SRC_BINDING_PATH
  # を明示して、feature 名を組み立てる処理ごと迂回させる。
  librustyV8SrcBinding = let
    shas = {
      x86_64-linux = "sha256-dyeCauR5vbZF6Acjn7EtH44uI956bPFvXuWSaQ0dhQY=";
      aarch64-linux = "sha256-dyeCauR5vbZF6Acjn7EtH44uI956bPFvXuWSaQ0dhQY=";
      x86_64-darwin = "sha256-ylrfDPicmnCtRgrnNkiy/om3SqETs8t/dXtqArdYOU8=";
      aarch64-darwin = "sha256-ylrfDPicmnCtRgrnNkiy/om3SqETs8t/dXtqArdYOU8=";
    };
  in pkgs.fetchurl {
    name = "src_binding-${librustyV8Version}";
    url =
      "https://github.com/denoland/rusty_v8/releases/download/v${librustyV8Version}/src_binding_release_${stdenv.hostPlatform.rust.rustcTarget}.rs";
    hash = shas.${stdenv.hostPlatform.system};
    meta = {
      version = librustyV8Version;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  };

  installShellCompletions =
    stdenv.buildPlatform.canExecute stdenv.hostPlatform;
in rustPlatform.buildRustPackage (finalAttrs: {
  pname = "codex";
  version = "0.156.1";

  src = pkgs.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${finalAttrs.version}";
    hash = "sha256-H53f57hmnyCtn5yPxtBe/A92qyQyzQBeU/vK2qSBrvI=";
  };

  sourceRoot = "${finalAttrs.src.name}/codex-rs";

  cargoHash = "sha256-W87rX/W2J1pwqNrihX+Rj6DfagoZYuB6C+l/S4BhyJM=";

  __structuredAttrs = true;

  # upstream の release ビルドに合わせる。codex 本体に加え、V8 をプロセス外で
  # 実行するためのランタイム companion である codex-code-mode-host も含める。
  cargoBuildFlags = [ "--package" "codex-cli" "--package" "codex-code-mode-host" ];
  cargoCheckFlags = [ "--package" "codex-cli" "--package" "codex-code-mode-host" ];

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'lto = "thin"' "" \
      --replace-fail 'codegen-units = 4' ""

    sed -i '1i#![recursion_limit = "256"]' chatgpt/src/lib.rs
  '';

  nativeBuildInputs = with pkgs; [
    clang
    cmake
    gitMinimal
    installShellFiles
    makeBinaryWrapper
    pkg-config
  ];

  buildInputs = with pkgs;
    [ libclang openssl ] ++ lib.optionals stdenv.hostPlatform.isLinux [ libcap ];

  # bindgen が libclang を見つけられるよう LIBCLANG_PATH を設定する。
  # あわせて既知の誤検知（BoringSSL の a_bitstr.cc に対する GCC の
  # stringop-overflow）で警告がエラー扱いにならないよう調整している。
  env = {
    LIBCLANG_PATH = "${lib.getLib pkgs.libclang}/lib";
    NIX_CFLAGS_COMPILE = toString
      (lib.optionals stdenv.cc.isGNU [ "-Wno-error=stringop-overflow" ]
        ++ lib.optionals stdenv.cc.isClang [ "-Wno-error=character-conversion" ]);
    RUSTY_V8_ARCHIVE = librustyV8;
    RUSTY_V8_SRC_BINDING_PATH = librustyV8SrcBinding;
  } // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Darwin では lld でリンクする。nixpkgs の従来の ld64 はこのバイナリ向けの
    # ARM64 branch thunk を挿入できず `b(l) ARM64 branch out of range` になる。
    NIX_CFLAGS_LINK = "-fuse-ld=${lib.getExe' pkgs.lld "ld64.lld"}";
  };

  # テストの一部がネットワークやローカルシェル等へのアクセスを要求するため無効化。
  # upstream の更新が非常に速く、スキップ対象の追従コストに見合わないため。
  doCheck = false;

  postInstall = lib.optionalString installShellCompletions ''
    installShellCompletion --cmd codex \
      --bash <($out/bin/codex completion bash) \
      --fish <($out/bin/codex completion fish) \
      --zsh <($out/bin/codex completion zsh)
  '';

  postFixup = ''
    wrapProgram $out/bin/codex --prefix PATH : ${
      lib.makeBinPath ([ pkgs.ripgrep ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [ pkgs.bubblewrap ])
    }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ pkgs.versionCheckHook ];

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    changelog =
      "https://raw.githubusercontent.com/openai/codex/refs/tags/rust-v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    platforms = lib.platforms.unix;
  };
})
