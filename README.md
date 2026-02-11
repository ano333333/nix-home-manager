# Home Manager 環境構築

このリポジトリは、NixのHome Managerを使用した環境構築のための設定ファイルです。

## 使用方法

クリーンなUbuntuのホームディレクトリでの実行を想定しています。

1. このリポジトリをクローン
2. `nix run .#update` を実行して環境を構築
3. 初回実行時にSSH鍵が自動生成されます
4. ~/.config/nvim/lua/にlsp-ai.jsonを配置する。記載は.config/home-manager/options/neovim/内の例を参考にすること

## 使用可能なコマンド

### 環境の更新
```bash
nix run .#update
```
フレークの更新とhome-managerの設定適用を一括で実行します。

### Docker初期化
```bash
nix run .#initDocker
```
Dockerの初期設定を実行します。

## セットアップ内容

### 基本設定
- ユーザー名
- メールアドレス
- Nixpkgs

### インストールされるパッケージ
- `git`
- `curl`

### プログラム設定
- **Git**: ユーザー名とメールアドレスを自動設定
- **SSH**: 有効化、ED25519鍵を非存在時に自動生成

## ディレクトリ構造

```
.
├── flake.nix                                    # Nixフレーク設定
├── flake.lock                                   # 依存関係ロックファイル
├── scripts/
│   └── homeManagerUpdate.sh                     # 更新スクリプト
└── .config/
    └── home-manager/
        ├── home.nix                             # メイン設定ファイル
        ├── options/
        │   └── git.nix                          # Git設定
        └── activations/
            └── generate-ssh-key.nix             # SSH鍵生成アクティベーション
```
