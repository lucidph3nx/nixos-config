{
  pkgs,
  pkgs-stable,
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import ./disko.nix {device = "/dev/nvme0n1";})
    inputs.disko.nixosModules.default
    inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
    inputs.nixos-hardware.nixosModules.microsoft-surface-common
    ../../modules
  ];

  nx = {
    sops = {
      ageKeys.enable = true;
      generalSecrets.enable = true;
      signingKeys.enable = true;
      homeSSHKeys.enable = true;
      kubeconfig.enable = true;
    };
    services = {
      syncthing = {
        enable = true;
        obsidian.enable = true;
        music.enable = false; # too large for a vm
      };
    };
    programs = {
      obsidian.enable = true;
      firefox.hideUrlbar = true;
    };
    # should be on home network
    nfs-mounts.enable = false; # not whitelisted on nas
  };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  networking.hostName = "surface";
  networking.networkmanager.enable = true;

  # home-manager is awesome
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit pkgs-stable;
    };
    users = {
      ben.imports = [
        ./home.nix
        ../../modules/home-manager
        ../../modules/colourScheme
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ffmpeg
    qpwgraph
    lm_sensors
  ];

  environment.sessionVariables = {
    # for kube
    KUBECONFIG = "${config.sops.secrets.homekube.path}";
  };

  fonts.fontDir.enable = true;
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  programs.sway = {
    enable = true;
    extraPackages = []; # I don't need foot etc bundled
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    wlr.enable = true;
  };

  # List services that you want to enable:
  services.dbus.implementation = "broker";

  security.rtkit.enable = true;

  # device specific syncthing config
  sops.secrets.surface-cert-pem = {
    owner = "ben";
    mode = "0600";
    sopsFile = ../../secrets/syncthingKeys.yaml;
  };
  sops.secrets.surface-key-pem = {
    owner = "ben";
    mode = "0600";
    sopsFile = ../../secrets/syncthingKeys.yaml;
  };
  services.syncthing.cert = config.sops.secrets.surface-cert-pem.path;
  services.syncthing.key = config.sops.secrets.surface-key-pem.path;

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
