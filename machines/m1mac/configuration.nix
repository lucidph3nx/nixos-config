{
  pkgs,
  inputs,
  nixpkgs-stable,
  nixpkgs-master,
  ...
}: {
  imports = [
    ../../modules/nix-darwin/yabai.nix
    # ../../modules/nix-darwin/spacebar.nix
  ];

  nix.settings.trusted-users = ["ben" "root"];

  users.users.ben = {
    home = "/Users/ben";
  };

  programs.zsh = {
    enable = true;
    shellInit = ''
      export ZDOTDIR=$HOME/.local/share/zsh
    '';
  };
  environment = {
    shells = [pkgs.bash pkgs.zsh];
    loginShell = pkgs.zsh;
    systemPackages = with pkgs; [
      arping
      awscli2
      azure-cli
      cloudflared
      direnv
      docker
      eza
      fzf
      fzy
      gh
      gnupg
      gnutar
      htop
      imagemagick
      jq
      openssh
      p7zip
      ripgrep
      rustup
      sops
      ssm-session-manager-plugin
      tree
      tridactyl-native
      utm
      yq-go
      zsh
    ];
  };
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  fonts.packages = [
    (pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];
  security.sudo.extraConfig = ''
    ben ALL=(ALL:ALL) NOPASSWD: ALL
  '';
  services = {
    nix-daemon.enable = true;
    karabiner-elements.enable = true;
  };
  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
    };
    dock = {
      autohide = true;
      # basically, permanantly hide dock
      autohide-delay = 1000.0;
      orientation = "left";
    };
    menuExtraClock = {
      IsAnalog = false;
      Show24Hour = true;
      ShowAMPM = false;
      ShowSeconds = true;
    };
    spaces = {
      spans-displays = false;
    };
    universalaccess = {
      reduceMotion = true;
      reduceTransparency = true;
    };
    NSGlobalDomain = {
      _HIHideMenuBar = false;
      InitialKeyRepeat = 14;
      KeyRepeat = 1;
      AppleInterfaceStyle = "Dark";
      AppleICUForce24HourTime = true;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
    };
  };
  homebrew = {
    enable = true;
    brews = [
      # "int128/kubelogin/kubelogin"
      "node"
      "borders" # JankyBorders
    ];
    taps = [
      "FelixKratz/formulae" # JankyBorders
    ];
    casks = [
      "nikitabobko/tap/aerospace"
      "1password"
      "1password-cli"
      "bitwarden"
      "firefox"
      "raycast"
      "scroll-reverser"
    ];
  };

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit nixpkgs-stable;
      inherit nixpkgs-master;
    };
    users = {
      ben.imports = [
        ./home.nix
        ../../modules
      ];
    };
  };
}
