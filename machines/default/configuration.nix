# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, nixpkgs-unstable, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # include sops
      inputs.sops-nix.nixosModules.sops
    ];
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # Configure keymap in X11
  services.xserver = {
	xkb = {
    		layout = "nz";
    		variant = "mao";
    	};
  };

  # no password for sudo
  security.sudo.wheelNeedsPassword = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ben = {
    isNormalUser = true;
    description = "ben";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # sops config
  sops = {
    defaultSopsFile = "./secrets/secrets.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "~/.config/sops/age/keys.txt";
    # test key
    secrets.example-key = { };
  };

  # Home Manager for user environment configuration
  #home-manager.users.ben = { pkgs, ... }: {
  #	home.packages = with pkgs; [
  #		kitty
  #		firefox
  #		neofetch
  #	];
  #	programs.zsh = {
  #		enable = true;
  #	};
  #	programs.git.enable = true;
  #	home.stateVersion = "23.11";
  #};
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; inherit nixpkgs-unstable;};
	  users = {
      ben.imports = [
        ./home.nix
      ];
	  };
  };


  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    aws-vault
    direnv
    eza
    flux
    fzf
    fzy
    gh
    imagemagick
    jq
    k9s
    kubectl
    ranger
    ripgrep
    rustup
    sops
    tree
    yq
    yt-dlp
    zsh
  ];

  fonts.fontDir.enable = true;
  fonts.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ];})
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.zsh.enable = true;
  # programs.neovim = {
  # 	enable = true;
  # 	defaultEditor = true;
  # };
  programs = {
  	sway = {
      enable = true;
      extraPackages = with pkgs; [
        swaylock
        swaynotificationcenter
      ];
    };
	  waybar.enable = true;
  };
  
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
    wlr.enable = true;
  };

  # List services that you want to enable:

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
