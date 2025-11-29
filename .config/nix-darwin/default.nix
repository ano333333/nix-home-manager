{
  pkgs,
  ...
}: {
  nix = {
    enable = false;
    settings = {
      experimental-features = "nix-command flakes";
      max-jobs = 8;
    };
  };

  system = {
    stateVersion = 6;
    primaryUser = "ano3";
    defaults = {
      NSGlobalDomain.AppleShowAllExtensions = true;
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
      };
      dock = {
        autohide = false;
        show-recents = true;
        orientation = "bottom";
        persistent-apps = [
          "/Applications/Ghostty.app"
        ];
      };
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
    };
    casks = [
      "ghostty"
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
}
