# NixOSでCLIP STUDIO PAINT 4を起動する

## 対象と現状

このリポジトリの `csp4` コマンドは、NixpkgsのWineとWinetricksを使い、
CSP専用の64bit Wine prefixを作る。既定の場所は
`~/.local/share/csp4/wineprefix`。既存の `~/.wine` は使用しない。
`CSP4_PREFIX=/絶対パス` で変更できる（すべての実行で同じ値を指定する）。

最初の対象は **Windows版4.0.10**。4.1.0向けコミュニティ手順を参考にした
段階的な検証用構成であり、このマシンでCSPの起動成功を確認した構成ではない。
ホストのペンタブは動作確認済み。Wine経由の筆圧はCSP起動後に確認する。

`configuration.nix` には既にWine、Winetricksと `hardware.graphics.enable32Bit`
があるため、以下の手順にNixOS/Home Managerの再適用は不要。
flakeの `csp4` はLinuxだけに公開している。

## 1. 環境を確認する

リポジトリのルートで、通常のデスクトップセッションから実行する。sudoは使わない。

```bash
nix run path:.#csp4 -- doctor
```

`path:.` は未追跡の追加ファイルも読み込むために使っている。
コマンドはflake.lockのNixpkgsでWineを固定する。現状のホストのWineは11.0。
HyprlandではXWaylandの `DISPLAY` があるセッションからまず試す。

## 2. 専用環境を準備する

```bash
nix run path:.#csp4 -- setup
```

Wine初期化後、`corefonts`、`cjkfonts`、`vcrun2022` をダウンロード・インストールする。
初回は時間がかかり、Wineのダイアログが出ることがある。
全体のWindows互換設定は10、`CLIPStudioPaint.exe` と `CLIPStudio.exe` は8.1にする。
VC++ランタイムの `concrt140` はnative,builtinに設定する。
失敗した場合は、そのエラーを解消してから再実行する。prefixを自動削除する処理はない。

これはまず本体の起動を試すための最小候補で、必要な依存関係をすべて特定した結果ではない。
参考の4.1.0用手順にはさらに.NET 4.8とDXVKがある。ベース構成で起動しない場合は、
CSPを終了してから同じprefixに追加し、再確認できる。

```bash
nix run path:.#csp4 -- winetricks -q dotnet48 dxvk
```

DXVKにはVulkan対応GPU・ドライバーが必要。.NETの導入は長時間かかる場合がある。

## 3. 公式インストーラーを実行する

[公式4.0ダウンロードページ](https://www.clipstudio.net/ja/dl/v4/)から
Windows版（調査時点4.0.10）をダウンロードする。
以下のパスは実際にダウンロードしたファイル名に合わせる。

```bash
nix run path:.#csp4 -- install "$HOME/Downloads/CSP_4010w_setup.exe"
```

インストーラー画面で使用許諾を確認し、通常のインストールを完了させる。
セットアップの「最後の設定」は時間がかかることがある。

4.0無期限版のライセンスで4.1.0は利用できない。4.1.0を試す場合は、
年額・月額利用プラン、アップデートプラン、または対応する新しい無期限版が必要。
[公式ライセンス対応表](https://support.clip-studio.com/ja-jp/faq/articles/20240070)

## 4. 本体を起動する

```bash
nix run path:.#csp4 -- paint
```

これは描画アプリ `CLIPStudioPaint.exe` を直接起動する。
ライセンス確認が必要なら、案内に従って自分のアカウントで認証する。
直接起動しても認証やWebView2が不要になるとは限らない。

ログイン・素材管理用のCLIP STUDIOは別に起動できる。

```bash
nix run path:.#csp4 -- studio
```

起動できたら新規キャンバスで描画、筆圧、保存・再読込を確認する。
筆圧だけ反映されない場合は、環境設定のタブレット設定にある
「タブレットドライバの設定でマウスモードを使用する」を試す。

## WebView2画面が白い／ログイン画面が出ない場合

このマシンではCSP 5系のインストール・起動後に白いウィンドウが出た。
調査時点で専用prefix内にWebView2 **115.0.1901.200** の実行ファイルがあった。
実行ファイルがあるだけでは、正常に登録・動作しているとは判断できない。

CSPとCLIP STUDIOを終了してから、次を実行する。

```bash
nix run path:.#csp4 -- setup-webview2
nix run path:.#csp4 -- doctor
nix run path:.#csp4 -- paint
```

`setup-webview2` はMicrosoft配布の **135.0.3179.85** のx64インストーラーを
ダウンロードして同じprefixに導入し、`msedgewebview2.exe` の互換設定だけを
Windows 7にする。CSP本体・ランチャーのWindows 10設定は変更しない。
この特定版はコミュニティのWine回避策に基づくもので、最新版ではなく、
CSP 5.1.5の白画面が直ると確認できたものでもない。

同じ版の実行ファイルがあれば再インストールを省略して互換設定を適用する。
インストーラーの終了コードと対象版のファイルの存在を確認するが、
認証画面の表示成功は別途確認が必要。より新しいRuntimeが入っている場合も、
自動アンインストール・ダウングレードはしない。
ログは `~/.cache/csp4/webview2/135.0.3179.85/install.log`
（`XDG_CACHE_HOME` 設定時はその配下）に残す。

本体の起動とWeb画面の動作は別に確認する。まずエラーログを残す。

```bash
nix run path:.#csp4 -- paint 2>&1 | tee /tmp/csp4-paint.log
nix run path:.#csp4 -- studio 2>&1 | tee /tmp/csp4-studio.log
```

参考の4.1.0用手順は、Microsoft EdgeとWebView2 **135.0.3179.85** を導入し、
`msedgewebview2.exe` だけWindows 7互換にする。これは特定版での回避策であり、
最新WebView2でも有効とは限らない。上記コマンドではEdgeブラウザー自体は導入しない。
WebView2導入だけで改善しなければ、参考先の手順とログを照合する。
手元にあるMicrosoft配布インストーラーを試す場合は次のように実行できる。

```bash
nix run path:.#csp4 -- wine "$HOME/Downloads/MicrosoftEdgeSetup.exe"
nix run path:.#csp4 -- wine "$HOME/Downloads/MicrosoftEdgeWebView2RuntimeInstallerX64.exe"
nix run path:.#csp4 -- wine reg add 'HKCU\Software\Wine\AppDefaults\msedgewebview2.exe' /v Version /t REG_SZ /d win7 /f
```

インストーラーの完了を確認してから次へ進む。時間だけで完了と判断して強制終了しない。
Wine設定画面は `nix run path:.#csp4 -- wine winecfg` で開ける。

## DirectCompositionの白画面対策（ソースビルド）

`scripts/csp-dcomp/` にCSPenguinのコミット
`868d022adfdc3740449241f4721debbf4b1b1426` のソースを固定している。
NixのMinGWで64bit `dcomp.dll` をビルドし、コンパイラーのランタイムは静的リンクする。
配布済みDLLや外部の `libwinpthread-1.dll` は使わない。

CSP・CLIP STUDIO・WebView2を閉じてから実行する。

```bash
nix run path:.#csp4 -- setup-dcomp
nix run path:.#csp4 -- paint
```

元の `system32/dcomp.dll` と `dcomp` のDLL優先設定を
prefix内の `csp-dcomp-backup` に初回だけ退避する。
CSP本体・WebView2のWindows互換設定は変更しない。
戻す場合もアプリを閉じ、次を実行する（バックアップは保持される）。

```bash
nix run path:.#csp4 -- restore-dcomp
```

レビューでは外部通信・認証情報を扱うコードは見当たらなかった。
ただし、描画APIのvtableを書き換える処理があり、未実装機能・性能負荷のほかに
互換性によるクラッシュや競合の可能性がある。
prefix内の `drive_c/dcomp-csp.log` は追記方式で、自動ローテーションはない。

このマシンでソースビルド・導入・CSP起動まで実施し、Wineのログで
`dcomp.dll ... native`、shimのログでテクスチャ作成と `Device::Commit` を確認した。
画面表示・認証の成功とは別の確認である。
起動ログは `/tmp/csp5-dcomp-paint.log`。

## 参考資料

- [CSP 4.1.0向けWine手順とスクリプト](https://github.com/kojiinari/CSP-on-linux-with-Wine)
- [同プロジェクトの移転先](https://codeberg.org/kojiinari/CSP-on-linux-with-Wine)
- [Ubuntuでの筆圧設定例（CSP 1.13.2対象）](https://blog.mikomon.net/post/clip-studio-linux)

依存関係・互換設定を分けた検証用コマンドとして実装しており、参考スクリプトの
全手順をそのまま再現したものではない。
