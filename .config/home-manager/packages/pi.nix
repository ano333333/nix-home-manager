{ pkgs }:
let
  version = "0.78.0";
  srcTarball = pkgs.fetchurl {
    url =
      "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-oEfadYAdkTXjaKRxHQbQyktqtwiAGrgv0TZt3h7t0O4=";
  };
  src = pkgs.runCommand "pi-${version}-src" {
    nativeBuildInputs = [
      pkgs.gnutar
      pkgs.gzip
      pkgs.perl
    ];
  } ''
    mkdir work
    tar -xzf ${srcTarball} -C work
    cd work/package

    substituteInPlace npm-shrinkwrap.json \
      --replace-fail '"resolved": "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-0.78.0.tgz",' \
                       '"resolved": "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-0.78.0.tgz","integrity": "sha512-xhWd59Qzd8yO88gYQw2S4dEQstJJEiUtxRP01//YzVJ61jCtUASMfcyAmYhgGYR4Onp7GmwEAbBBGOiV6Iwk9g==",'
    substituteInPlace npm-shrinkwrap.json \
      --replace-fail '"resolved": "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-0.78.0.tgz",' \
                       '"resolved": "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-0.78.0.tgz","integrity": "sha512-q0hUrvT6ngT6cgBX0oIbzfQfmzztgdkZobP8OTL+sCOOBlnG6+1YRt8g7zO9CC/4NdeYEqa7uGqWdQhH0fjCLA==",'
    substituteInPlace npm-shrinkwrap.json \
      --replace-fail '"resolved": "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-0.78.0.tgz",' \
                       '"resolved": "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-0.78.0.tgz","integrity": "sha512-3a705FnsVVUhAyceShNB3kS2rpxcxLcx+hqB0u6MMMpHwQGbW+m++MqA6r7eOzq/8FLx5e3vDh38h/SVTk2qzw==",'
    cp npm-shrinkwrap.json package-lock.json
    substituteInPlace package.json \
      --replace-fail '"devDependencies": {
		"@types/cross-spawn": "6.0.6",
		"@types/diff": "7.0.2",
		"@types/hosted-git-info": "3.0.5",
		"@types/ms": "2.1.0",
		"@types/node": "24.12.4",
		"@types/proper-lockfile": "4.1.4",
		"shx": "0.4.0",
		"typescript": "5.9.3",
		"vitest": "3.2.4"
	},' \
                       '"devDependencies": {},'

    mkdir -p $out
    cp -r . $out/
  '';
in
pkgs.buildNpmPackage {
  pname = "pi";
  inherit version src;

  nodejs = pkgs.nodejs_22;
  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-GkTfbND2WFKrrqFnKbLtiFMfS2+fpX+ZYfqUvoQrzm4=";
  npmInstallFlags = [
    "--omit=dev"
  ];

  dontCheck = true;
  dontNpmBuild = true;

  meta = {
    description = "Pi coding agent CLI";
    homepage = "https://pi.dev/docs/latest";
    mainProgram = "pi";
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.unix;
  };
}
