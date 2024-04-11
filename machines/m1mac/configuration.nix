{ pkgs, nixpkgs-unstable, inputs, ... }:

{
  imports =
  [
      ../../modules/nix-darwin/yabai.nix
      # ../../modules/nix-darwin/spacebar.nix
  ];

  users.users.ben = {
    home = "/Users/ben";
  };

  programs.zsh.enable = true;
  environment = {
    shells = [ pkgs.bash pkgs.zsh ];
    loginShell = pkgs.zsh;
    systemPackages = with pkgs; [
      arping
      aws-vault
      awscli2
      azure-cli
      direnv
      docker
      eza
      fzf
      fzy
      gh
      gnupg
      gnutar
      imagemagick
      jq
      p7zip
      ripgrep
      rustup
      sops
      tree
      tridactyl-native
      yq
      zsh
      # example unstable
      # nixpkgs-unstable.mise
    ];
  };
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  fonts.fontDir.enable = true;
  fonts.fonts = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ];})
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
    enable =  true;
    brews = [
      "int128/kubelogin/kubelogin"
    ];
    casks = [
      "1password"
      "1password-cli"
      "bitwarden"
      "firefox"
      "raycast"
      "scroll-reverser"
      "spaceman"
    ];
  };

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; inherit nixpkgs-unstable;};
    users = {
      ben.imports = [
        ./home.nix
        ../../modules
      ];
    };
  };
}
