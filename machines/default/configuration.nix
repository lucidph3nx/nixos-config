# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, nixpkgs-unstable, inputs, config, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/nix
    ];

  nixModules.sops = {
    generalSecrets.enable = true;
    signingKeys.enable = true;
    homeSSHKeys.enable = true;
    workSecrets.enable = false;
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NZ.UTF-8";
    LC_IDENTIFICATION = "en_NZ.UTF-8";
    LC_MEASUREMENT = "en_NZ.UTF-8";
    LC_MONETARY = "en_NZ.UTF-8";
    LC_NAME = "en_NZ.UTF-8";
    LC_NUMERIC = "en_NZ.UTF-8";
    LC_PAPER = "en_NZ.UTF-8";
    LC_TELEPHONE = "en_NZ.UTF-8";
    LC_TIME = "en_NZ.UTF-8";
  };

  # no password for sudo
  security.sudo.wheelNeedsPassword = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ben = {
    isNormalUser = true;
    description = "ben";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };
  # seems to be needed for something 🤷
  # programs.dconf.enable = true;

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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    arping
    aws-vault
    chromium
    curl
    direnv
    eza
    fzf
    fzy
    gh
    htop
    imagemagick
    jq
    killall
    p7zip
    ripgrep
    rustup
    sops
    tree
    xdg-utils
    yq
    yt-dlp
    zsh
  ];

  environment.sessionVariables = {
    # for sway
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
    # secrets
    HASS_API_KEY = "$(cat ${config.sops.secrets.hass_api_key.path})";
    SECRET_DOMAIN = "$(cat ${config.sops.secrets.secret_domain.path})";
  };

  fonts.fontDir.enable = true;
  fonts.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ];})
  ];


  programs.zsh.enable = true;
  programs.sway.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    wlr.enable = true;
    config = {
      sway = {
        default = [
          "wlr"
          "gtk"
        ];
      };
    };
  };

  # List services that you want to enable:
  services.dbus.implementation = "broker";
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # display manager
  services.greetd = {
  	enable = true;
    restart = true;
    package = pkgs.greetd.tuigreet;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --time-format '%Y-%m-%d %H:%M:%S' --cmd sway";
        user = "greeter";
      };
    };
  };
  # cups for printing
  services.printing.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
