# WaydroidでibisPaintを使う

`configuration.nix` の `virtualisation.waydroid.enable` でWaydroid、LXC、
コンテナサービス、`waydroid0` のファイアウォール設定を有効にする。
Waydroidのパッケージは `pkgs.waydroid-nftables` を明示する。
標準パッケージはiptables-legacyを優先するため、この環境では
`Module ip_tables not found` により `waydroid-net.sh start` が失敗する。
AndroidイメージとアプリのデータはNixの構成には含まれない。

## 初回セットアップ

リポジトリの現在の構成全体（Home Managerを含む）を適用する。
未追跡ファイルも読み込むため `path:` を使う。

```sh
cd ~/nix-home-manager
sudo nixos-rebuild switch --flake path:.#nixos
sudo waydroid init -s GAPPS
sudo systemctl restart waydroid-container
waydroid show-full-ui
```

GAPPSはGoogle Playを含むイメージ。ダウンロードには時間がかかる。
GUIはsudoを付けず、ログイン中のWayland端末から起動する。
NixOSモジュールはカーネル引数 `psi=1` も設定するため、初回適用後に
起動できない場合は再起動してから上のコンテナ再起動・GUI起動を試す。

## Google PlayとibisPaint X

初回に「デバイスが認定されていない」と出た場合は、Androidが起動した状態で
以下を実行し、表示されたIDをGoogleの登録ページに登録する。

```sh
sudo waydroid shell -- sh -c 'sqlite3 /data/data/*/*/gservices.db '\''select value from main where name = "android_id";'\'''
```

- 登録先: <https://www.google.com/android/uncertified>
- 公式手順: <https://docs.waydro.id/faq/google-play-certification>

登録の反映を数分待ち、`waydroid session stop` の後に
`waydroid show-full-ui` で再起動する。Googleアカウントのログインは画面上で行う。
Playストアで **ibis Paint X（ibis inc.）** をインストールする。

- 公式配布: <https://play.google.com/store/apps/details?id=jp.ne.ibis.ibispaintx.app>
- インストール後の起動: `waydroid app launch jp.ne.ibis.ibispaintx.app`

ストアに表示されない／非対応と表示される場合は、まずABIとログを確認する。
ARM専用アプリはx86_64版Waydroid標準構成では実行できない。
ARM変換層はこの構成ではまだ追加していない。

```sh
sudo waydroid shell -- getprop ro.product.cpu.abilist
waydroid status
sudo journalctl -u waydroid-container -b -n 100 --no-pager
sudo waydroid logcat > /tmp/waydroid-logcat.txt
```

`logcat` は必要な操作を再現した後にCtrl-Cで止める。
導入後は描画と筆圧、新規作品の保存・再オープン、PNGの書き出し、
画像の取り込みを確認する。ホストでの筆圧動作とAndroid内の動作は別途確認が必要。

## 参考

- <https://docs.waydro.id/usage/waydroid-command-line-options>
- <https://docs.waydro.id/usage/install-and-run-android-applications>
