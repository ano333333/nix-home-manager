# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## 概要

このリポジトリは、Home Managerを使用したNixフレークベースのクロスプラットフォーム開発環境設定です（Linux x86_64とmacOS aarch64/Apple Silicon対応）。macOSのシステム設定用のnix-darwin設定も含まれています。

## よく使うコマンド

### 環境の更新
```bash
nix run .#update
```
home-manager設定の適用を実行します。macOSではnix-darwin設定も適用されます。設定変更を反映するための主要コマンドです。

### flake.lockの更新
```bash
nix run .#updateFlake
```
flake.lockを更新します。

**注意：macOSでの既知の問題**
現在、macOS (darwin) では `nix run .#update` がエラーを起こす問題があります。回避策として、以下のコマンドでスクリプトを直接実行してください：
```bash
./scripts/homeManagerUpdate.sh
```

### Dockerのインストール（Linuxのみ）
```bash
nix run .#initDocker
```
.debパッケージからDockerをインストールし、サービスを開始、現在のユーザーをdockerグループに追加します。

### 手動でのHome Manager適用
```bash
# Linux
nix run nixpkgs#home-manager -- switch --flake .#linux

# macOS
nix run nixpkgs#home-manager -- switch --flake .#darwin
sudo nix run nix-darwin -- switch --flake .#darwin
```

### 設定変更のテスト
```bash
# inputsを変更した後にflake.lockを更新
nix flake update

# 構文エラーのチェック
nix flake check
```

## アーキテクチャ

### Flake構造
- `flake.nix` - LinuxとmacOS両方のinputs、outputs、appsを定義するエントリーポイント
- 主要な設定出力：
  - `homeConfigurations.linux` - Linux用Home Manager
  - `homeConfigurations.darwin` - macOS用Home Manager
  - `darwinConfigurations.darwin` - nix-darwinシステム設定
- システムごとに3つのapp出力：`update`、`updateFlake`、`initDocker`

### Home Manager設定
メイン設定ファイル：`.config/home-manager/home.nix`

主要なアーキテクチャパターン：
- ユーザー名とメールアドレスはhome.nixの先頭で定義（`ano3` / `ano333333github@gmail.com`）
- `system`パラメータによるプラットフォーム検出でhomeDirectoryパスを決定
- サブディレクトリからのインポートによるモジュール構成

モジュール構造：
- `options/` - プログラム固有の設定（git.nix、starship.nix、neovim.nix、zsh設定）
- `packages/` - カスタムパッケージ定義（asdf.nix、neovim-plugins.nix）
- `activations/` - Home Managerアクティベーションスクリプト（generate-ssh-key.nix）
- `font.nix` - フォントパッケージ
- `options/ghostty` - Ghosttyターミナル設定

### Git設定戦略
Gitは文脈に応じて条件付きincludeを使用：
- デフォルト：`~/.gitconfig`（Home Managerで管理）
- プライベートリポジトリ：`~/private/` → `~/.gitconfig.private`（ユーザーが手動管理）
- AIリポジトリ：`~/ai/` → `~/.gitconfig.ai`（Home Managerで`.config/home-manager/options/.gitignore.ai`から管理）

デフォルトSSH鍵：`~/.ssh/id_ed25519`

### SSH鍵の生成
SSH鍵（id_ed25519とid_ed25519_2）は、存在しない場合にHome Managerのアクティベーションスクリプトで自動生成されます。これは`home-manager switch`の実行時に毎回チェックされます。

### システム固有の設定

**Linux (x86_64-linux)**：
- ホームディレクトリ：`/home/ano3`
- カスタムスクリプトによるDockerインストール

**macOS (aarch64-darwin)**：
- ホームディレクトリ：`/Users/ano3`
- nix-darwinがシステムデフォルト設定を管理（Finder、Dock、タイムゾーン）
- GhosttyターミナルのHomebrew統合
- タイムゾーン：`Asia/Tokyo`

### Python環境
asdfのビルド問題の一時的な回避策として、Python 3.12がNix経由でグローバルにインストールされています。pythonとpipコマンド用のシンボリックリンクが`~/.bin/`に作成されます。

### シェル設定
- zinitプラグインマネージャー付きZsh
- 拡張補完とスニペット用のzeno.zsh
- Starshipプロンプト
- プロジェクトごとの環境用のdirenvとnix-direnv
- 設定ファイル：`.config/home-manager/options/zsh/zeno.yml`

## 開発ワークフロー

### パッケージの追加
`.config/home-manager/home.nix`の`home.packages`配列に追加し、`nix run .#update`を実行します。

### プログラムオプションの変更
`.config/home-manager/options/`内のファイルを編集し、`nix run .#update`を実行します。

### 新しいアクティベーションスクリプトの追加
`.config/home-manager/activations/`に配置し、home.nixでインポートします。順序制御には`lib.hm.dag.entryAfter`を使用します。

### プラットフォーム固有の変更
`system`パラメータに基づいた条件式を使用：
```nix
if system == "x86_64-linux" then ...
else if system == "aarch64-darwin" then ...
else throw "Unsupported system: ${system}"
```

### scriptsディレクトリ
`scripts/`には以下が含まれます：
- `homeManagerUpdate.sh` - flake appでラップされる更新ロジック
- `flakeUpdate.sh` - flake.lock更新ロジック
- `initDocker.nix` - Linux用Dockerインストール
- `installHomebrew.sh` - Homebrewインストールヘルパー

## 重要な注意事項

- この設定は、Linux上のクリーンなUbuntuホームディレクトリとApple Silicon Macを想定して設計されています
- ステートバージョン：24.05（この値は変更しないでください）
- nixpkgs.config.allowUnfree経由でアンフリーパッケージが許可されています
- nix-darwinステートバージョン：6
- nixファイルを変更する際は、既存のスタイルに合わせて2スペースインデントを使用してください
- このリポジトリはコメントとコミットメッセージに日本語を使用しています
