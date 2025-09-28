{
  email,
}:{
  enable = true;
  userName = "ano333333";
  userEmail = email;
  extraConfig = {
    core = {
      sshCommand = "ssh -i ~/.ssh/id_ed25519";
    };
  };

  # プライベートのアカウント用の.gitconfigはincludeIfで読み込む
  includes = [
    {
      condition = "gitdir:~/private/";
      path = "~/.gitconfig.private";
    }
  ];
}
