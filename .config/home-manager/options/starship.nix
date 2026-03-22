{
  enable = true;
  settings = {
    # シェルプロンプトの間に空行を挿入する
    add_newline = true;

    character = {
      # 前のコマンドが成功した場合にテキスト入力の前に使用されるフォーマット文字列
      success_symbol = "[➜](bold green)";
      # 前のコマンドが失敗した場合にテキスト入力の前に使用されるフォーマット文字列
      error_symbol = "[➜](bold red)";
    };

    package = {
      # package モジュールを無効化してプロンプトから完全に非表示にする
      disabled = true;
    };

    gcloud = { disabled = true; };
  };
}

