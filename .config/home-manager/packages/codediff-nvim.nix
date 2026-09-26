{ pkgs, codediff-nvim }:
let
  # codediff.nvimはファイル監視用のcodediff-watcherを初回起動時に
  # プラグインディレクトリへダウンロードしようとするが、nix storeは
  # 読み取り専用で失敗するため、事前に取得してプラグインに同梱する
  # バージョンはlua/codediff/core/installer/watcher.luaのVERSIONに合わせる
  version = "0.23.2";
  sources = {
    x86_64-linux = {
      platform = "linux-x64";
      hash = "sha256-acXsKVZCUZ952p57kIkK0TLw/YDiiD9v9pZxBqAF27w=";
    };
    aarch64-darwin = {
      platform = "macos-arm64";
      hash = "sha256-LOudhXiteUsNAYkwbwTQdf7GEdLAYfeL24q4SBri0t4=";
    };
  };
  system = pkgs.stdenv.hostPlatform.system;
  source = sources.${system} or (throw "Unsupported system: ${system}");
  codediff-watcher = pkgs.stdenv.mkDerivation {
    pname = "codediff-watcher";
    inherit version;
    src = pkgs.fetchurl {
      url =
        "https://github.com/esmuellert/codediff/releases/download/v${version}/codediff-watcher-${version}-${source.platform}.tar.gz";
      inherit (source) hash;
    };
    sourceRoot = ".";
    nativeBuildInputs =
      pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.autoPatchelfHook ];
    buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.libgcc ];
    installPhase = ''
      install -Dm755 codediff-watcher $out/bin/codediff-watcher
    '';
  };
in codediff-nvim.overrideAttrs (old: {
  postInstall = (old.postInstall or "") + ''
    ln -s ${codediff-watcher}/bin/codediff-watcher $out/codediff-watcher
  '';
})
