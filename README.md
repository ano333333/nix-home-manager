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

home-managerの設定適用を実行します。

### flake.lockの更新

```bash
nix run .#updateFlake
```

flake.lockを更新します。

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
│   ├── homeManagerUpdate.sh                     # home-manager適用スクリプト
│   └── flakeUpdate.sh                           # flake更新スクリプト
└── .config/
    └── home-manager/
        ├── home.nix                             # メイン設定ファイル
        ├── options/
        │   └── git.nix                          # Git設定
        └── activations/
            └── generate-ssh-key.nix             # SSH鍵生成アクティベーション
```

## 導入済みskills

- [tokoroten/prompt-review prompt-review#0a83fd9eeead58fe92d0b04522da9e6840a71940](https://github.com/tokoroten/prompt-review/tree/0a83fd9eeead58fe92d0b04522da9e6840a71940)
- [mizchi/chezmoi-dotfiles empirical-prompt-tuning#c7845a843b54f349113435e8f5f48705ce59acf2](https://github.com/mizchi/chezmoi-dotfiles/tree/c7845a843b54f349113435e8f5f48705ce59acf2)
- [pencil.dev CLI用SKILL(@0.2.6)](https://unpkg.com/@pencil.dev/cli@0.2.6/SKILL.md)
- [herdr/SKILL.md#813fec141faabe0615b66c4f1738c0af7581309c](https://github.com/ogulcancelik/herdr/tree/813fec141faabe0615b66c4f1738c0af7581309c)
- [genshijin/skills/genshijin/SKILL.md#161bd988d0ab5d450f0b14f85d044d361627830a](https://github.com/InterfaceX-co-jp/genshijin/blob/main/skills/genshijin/SKILL.md)
- [genshijin/skills/genshijin-crew/SKILL.md#161bd988d0ab5d450f0b14f85d044d361627830a](https://github.com/InterfaceX-co-jp/genshijin/blob/main/skills/genshijin-crew/SKILL.md)
- [superpowers/skills#d884ae04edebef577e82ff7c4e143debd0bbec99](https://github.com/obra/superpowers/tree/d884ae04edebef577e82ff7c4e143debd0bbec99/skills)
- [coji/natural-japanese#9a78a42964096da509b8f3e011f0085a5f080151](https://github.com/coji/natural-japanese/tree/9a78a42964096da509b8f3e011f0085a5f080151)
- [nanaism/yomiyasu#86c98ac800aa0f1d95baf9c7c558856aab4efbae](https://github.com/nanaism/yomiyasu/tree/86c98ac800aa0f1d95baf9c7c558856aab4efbae)
- [oh-my-mermaid/oh-my-mermaid/skills/omm-scan/SKILL.md#38ccdb69298adec949177c92c88d6e3ddfb5bab7](https://github.com/oh-my-mermaid/oh-my-mermaid/blob/38ccdb69298adec949177c92c88d6e3ddfb5bab7/skills/omm-scan/SKILL.md)
- [oh-my-mermaid/oh-my-mermaid/skills/omm-view/SKILL.md#38ccdb69298adec949177c92c88d6e3ddfb5bab7](https://github.com/oh-my-mermaid/oh-my-mermaid/blob/38ccdb69298adec949177c92c88d6e3ddfb5bab7/skills/omm-view/SKILL.md)
