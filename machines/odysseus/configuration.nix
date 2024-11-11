{
  pkgs,
  pkgs-stable,
  pkgs-master,
  inputs,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    ../../modules/nix
  ];

  nixModules = {
    sops = {
      ageKeys.enable = true;
      generalSecrets.enable = true;
      signingKeys.enable = true;
      homeSSHKeys.enable = true;
      kubeconfig.enable = true;
    };
    syncthing = {
      enable = true;
      obsidian.enable = true;
      music.enable = false; # too large for a vm
    };
    greetd.command = "sway";
    # should be on home network
    nfs-mounts.enable = false; # not whitelisted on nas
  };

  nixpkgs.overlays = [
    inputs.nixos-apple-silicon.overlays.apple-silicon-overlay
    (final: prev: { mesa = final.mesa-asahi-edge; })
  ];

  hardware = {
    asahi = {
      peripheralFirmwareDirectory = ./firmware;
      useExperimentalGPUDriver = true;
      experimentalGPUInstallMode = "driver";
      setupAsahiSound = true;
      withRust = true;
    };
    graphics.enable = true;
  };
  boot.consoleLogLevel = 0;
  boot.kernelParams = ["apple_dcp.show_notch=1"];
  boot.loader.efi.canTouchEfiVariables = false;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  # https://github.com/nix-community/impermanence/issues/229
  boot.initrd.systemd.suppressedUnits = [ "systemd-machine-id-commit.service" ];
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  boot.kernel.sysctl."net.core.rmem_max" = 2500000;

  # things to persist
  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      {
        directory = "/var/lib/private/ollama";
        user = "ollama";
        group = "ollama";
        mode = "700";
      }
      "/var/lib/waydroid"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/sops-nix"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
  # without these, you will get errors the first time after install
  system.activationScripts.persistDirs = ''
    mkdir -p /persist/system/var/log
    mkdir -p /persist/system/var/lib/nixos
    mkdir -p /persist/cache
    chown -R ben:users /persist/cache
    mkdir -p /persist/home/ben
    mkdir -p /persist/home/ben/.ssh
    mkdir -p /persist/home/ben/.local/share/Steam
    chown -R ben:users /persist/home/ben
  '';

  networking.hostName = "odysseus"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  # no password for sudo
  security.sudo.wheelNeedsPassword = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ben = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.ben_hashed_password.path;
    description = "ben";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
  };

  # needed for impermanance in home-manager
  programs.fuse.userAllowOther = true;
  # home-manager is awesome
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit pkgs-stable;
      inherit pkgs-master;
    };
    users = {
      ben.imports = [
        ./home.nix
        ../../modules
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  # ];

  environment.sessionVariables = {
    # for kube
    KUBECONFIG = "${config.sops.secrets.homekube.path}";
  };

  # fonts.fontDir.enable = true;
  # fonts.packages = [
  #   (pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})
  # ];

  # programs.sway = {
  #   enable = true;
  #   extraPackages = []; # I don't need foot etc bundled
  # };
  # programs.hyprland.enable = true;
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = with pkgs; [
  #     xdg-desktop-portal-wlr
  #     xdg-desktop-portal-gtk
  #   ];
  #   wlr.enable = true;
  # };

  # List services that you want to enable:
  services.dbus.implementation = "broker";
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # cups for printing
  # services.printing.enable = true;

  # device specific syncthing config
  sops.secrets.default-cert-pem = {
    owner = "ben";
    mode = "0600";
    sopsFile = ../../secrets/syncthingKeys.yaml;
  };
  sops.secrets.default-key-pem = {
    owner = "ben";
    mode = "0600";
    sopsFile = ../../secrets/syncthingKeys.yaml;
  };
  services.syncthing.cert = config.sops.secrets.default-cert-pem.path;
  services.syncthing.key = config.sops.secrets.default-key-pem.path;

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
  system.stateVersion = "24.05"; # Did you read the comment?
}
