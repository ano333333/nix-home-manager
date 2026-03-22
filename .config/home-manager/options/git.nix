{ email, }: {
  enable = true;
  settings = {
    user = {
      inherit email;
      name = "ano3";
    };
    core = { sshCommand = "ssh -i ~/.ssh/id_ed25519"; };
    pager = {
      diff = "delta";
      log = "delta";
      show = "delta";
      blame = "delta";
    };
    delta = {
      navigate = true;
      dark = true;
      line-numbers = true;
    };
  };

  includes = [
    # プライベートのアカウント用の.gitconfigはincludeIfで読み込む
    {
      condition = "gitdir:~/private/";
      path = "~/.gitconfig.private";
    }
    # AI用のプロファイルをincludeIfで読み込む
    {
      condition = "gitdir:~/ai/";
      path = "~/.gitconfig.ai";
    }
  ];

  ignores = [
    # direnv, nix-direnvのignore
    ".envrc"
    ".direnv/"
  ];
}
