{ pkgs }:
pkgs.buildNpmPackage (finalAttrs: {
  pname = "oh-my-mermaid";
  version = "0.2.0";

  src = pkgs.fetchFromGitHub {
    owner = "oh-my-mermaid";
    repo = "oh-my-mermaid";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kMo8nmyuuaL16QwXxPcLHS3F64vSLfNCgXM31vUUgPo=";
  };

  npmDepsHash = "sha256-B6+dxmh4cdItS3QvTIkxt6/YAEnjVs1dIY86e/9uGEA=";

  # omm push等のクラウド連携は使わないため、API URLを空文字にして外部通信を封じる。
  # getApiUrl()は`OMM_API_URL || DEFAULT_API_URL`なので、環境変数の空文字だけでは
  # デフォルトURLに戻ってしまう。そのためデフォルトURL自体も空文字に差し替える
  postPatch = ''
    substituteInPlace src/lib/cloud.ts \
      --replace-fail "const DEFAULT_API_URL = 'https://ohmymermaid.com';" \
                     "const DEFAULT_API_URL = ''';"
  '';

  nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

  postFixup = ''
    wrapProgram $out/bin/omm --set OMM_API_URL ""
  '';

  meta = {
    description =
      "Turn complex codebases into clear, navigable architecture diagrams";
    homepage = "https://github.com/oh-my-mermaid/oh-my-mermaid";
    license = pkgs.lib.licenses.mit;
    mainProgram = "omm";
  };
})
