{
  email,
}:
{
  enable = true;
  userName = "ano333333";
  userEmail = email;
  extraConfig = {
    core = {
      sshCommand = "ssh -i ~/.ssh/id_ed25519";
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
