# Blender Lab公式のMCP (https://www.blender.org/lab/mcp-server/)
#
# 2つのコンポーネントで構成される:
# - server: MCPクライアントがstdioで起動するサーバー (blender-mcp)
# - blender: MCPアドオンを同梱し、起動時に自動で有効化するBlenderのラッパー
#
# MCP Client <= stdio => blender-mcp <= TCP(localhost:9876) => Blenderアドオン
{ pkgs, blender }:
let
  inherit (pkgs) lib;
  version = "1.0.3";
  repo = pkgs.fetchgit {
    url = "https://projects.blender.org/lab/blender_mcp.git";
    rev = "refs/tags/v${version}";
    hash = "sha256-pYeByO4Oi5eyynsJhGVd1vBWXHvhGn+Y5LGit6Kazlw=";
  };

  # BLENDER_SYSTEM_EXTENSIONSに指定するディレクトリ
  # <dir>/system/<id> が "System" リポジトリの拡張機能として読み込まれる
  systemExtensions = pkgs.runCommand "blender-mcp-system-extensions" { } ''
    mkdir -p $out/system
    cp -r ${repo}/addon/blender_mcp_addon $out/system/mcp
  '';

  # BLENDER_SYSTEM_SCRIPTSに指定するディレクトリ
  # startupスクリプトの実行時点では拡張機能が未初期化のため、タイマーで遅延させて有効化する
  # (--addonsフラグではプリファレンスに登録されず、アドオンのregister()が失敗する)
  systemScripts = pkgs.writeTextDir "startup/enable_blender_mcp.py" ''
    import addon_utils
    import bpy

    _MODULE = "bl_ext.system.mcp"


    def _enable():
        if _MODULE not in bpy.context.preferences.addons:
            addon_utils.enable(_MODULE, default_set=True, persistent=True)


    def register():
        bpy.app.timers.register(_enable, first_interval=0.0)


    def unregister():
        pass
  '';

  wrappedBlender = pkgs.symlinkJoin {
    name = "blender-${blender.version}-with-mcp";
    paths = [ blender ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    # アドオンはオンラインアクセスが許可されていないとサーバーを起動しないため--online-modeを付与
    postBuild = ''
      wrapProgram $out/bin/blender \
        --set BLENDER_SYSTEM_EXTENSIONS ${systemExtensions} \
        --set BLENDER_SYSTEM_SCRIPTS ${systemScripts} \
        --add-flags --online-mode
    '';
    inherit (blender) meta;
  };

  server = pkgs.python3Packages.buildPythonApplication {
    pname = "blender-mcp";
    inherit version;
    src = "${repo}/mcp";
    pyproject = true;

    build-system = [ pkgs.python3Packages.setuptools ];
    dependencies = with pkgs.python3Packages;
      [ docutils mcp pyyaml ] ++ mcp.optional-dependencies.cli;

    # レンダリング等のツールがBlenderをCLIで呼び出す際に使うパス
    makeWrapperArgs = [ "--set BLENDER_PATH ${wrappedBlender}/bin/blender" ];

    pythonImportsCheck = [ "blmcp" ];

    meta = {
      description = "MCP server for Blender";
      homepage = "https://projects.blender.org/lab/blender_mcp";
      license = lib.licenses.gpl3Plus;
      mainProgram = "blender-mcp";
    };
  };
in {
  blender = wrappedBlender;
  inherit server;
}
