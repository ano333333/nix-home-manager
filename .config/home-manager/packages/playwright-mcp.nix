{ pkgs }:
let
  # Playwrightブラウザのパス設定
  browsers = (builtins.fromJSON
    (builtins.readFile "${pkgs.playwright-driver}/browsers.json")).browsers;
  chromium-revision = (builtins.head
    (builtins.filter (x: x.name == "chromium") browsers)).revision;
  chromiumPath = if pkgs.stdenv.isLinux then
    "${pkgs.playwright-driver.browsers}/chromium-${chromium-revision}/chrome-linux/chrome"
  else
    "${pkgs.playwright-driver.browsers}/chromium-${chromium-revision}/chrome-mac/Chromium.app/Contents/MacOS/Chromium";

  # microsoft/playwright-mcpをfetchGitHubで取得
  playwright-mcp-src = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-mcp";
    rev = "v0.0.68";
    sha256 = "sha256-TPO2fUOfBWJjk2Qz7Tc5jKyPrkR8RYd1sSxWYlcx8pg=";
  };
in pkgs.buildNpmPackage {
  pname = "playwright-mcp";
  version = "0.0.68";

  src = playwright-mcp-src;

  # npmDepsHashはnix build時に正しいハッシュを計算して再設定する必要がある
  npmDepsHash = "sha256-ekJR38hnohiSrYxHTMmiquuCCS5h/H/T/jCe66mJ6PQ=";

  # workspace全体をビルドする
  dontNpmBuild = false;

  # シンボリックリンクのチェックを無効化
  dontFixup = true;

  # installPhaseをオーバーライドして、ビルド済みのファイルを直接配置する
  installPhase = ''
    runHook preInstall

    # 出力ディレクトリを作成
    mkdir -p $out/bin $out/lib

    # packages/playwright-mcpのビルド済みファイルをコピー
    if [ -d "packages/playwright-mcp" ]; then
      cp -r packages/playwright-mcp $out/lib/playwright-mcp
    fi

    # node_modulesもコピー（依存関係が必要）
    if [ -d "node_modules" ]; then
      cp -r node_modules $out/lib/playwright-mcp/
    fi

    # cli.jsへのラッパースクリプトを作成
    cat > $out/bin/playwright-mcp <<'WRAPPER_EOF'
    #!/bin/sh
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

    # ユーザーデータディレクトリを設定（書き込み可能な場所）
    USER_DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/playwright-mcp"
    mkdir -p "$USER_DATA_DIR"

    # デフォルト引数を設定
    # --executable-pathでNixストアのブラウザを直接指定
    # --no-sandboxでサンドボックスを無効化（Nixストア内のブラウザでは必要）
    DEFAULT_ARGS="--no-sandbox --user-data-dir=$USER_DATA_DIR --executable-path=CHROMIUM_PATH_PLACEHOLDER"

    # デフォルト引数とユーザー引数をマージ
    exec NODE_PATH_PLACEHOLDER LIB_PATH_PLACEHOLDER/cli.js $DEFAULT_ARGS "$@"
    WRAPPER_EOF

    # プレースホルダーを実際のパスに置換
    sed -i "s|CHROMIUM_PATH_PLACEHOLDER|${chromiumPath}|g" $out/bin/playwright-mcp
    sed -i "s|NODE_PATH_PLACEHOLDER|${pkgs.nodejs_24}/bin/node|g" $out/bin/playwright-mcp
    sed -i "s|LIB_PATH_PLACEHOLDER|$out/lib/playwright-mcp|g" $out/bin/playwright-mcp

    chmod +x $out/bin/playwright-mcp

    # MCPサーバーとして使えるように、エイリアスも作成
    ln -s $out/bin/playwright-mcp $out/bin/mcp-server-playwright

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description =
      "Playwright MCP server - Browser automation capabilities for LLMs";
    homepage = "https://github.com/microsoft/playwright-mcp";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = [ "x86_64-linux" "aarch64-darwin" ];
  };
}
