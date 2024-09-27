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
    (import ./disko.nix {device = "/dev/vda";})
    inputs.disko.nixosModules.default
    ../../modules/nix
  ];

  nixModules = {
    sops = {
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

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  # Wipe the disk on each boot
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/root_vg/root /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  # things to persist
  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
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
    mkdir -p /persist/home/ben
    mkdir -p /persist/home/ben/.ssh
    chown -R ben:users /persist/home/ben
  '';

  networking.hostName = "default"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

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

  fonts.fontDir.enable = true;
  fonts.packages = [
    (pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];

  programs.sway = {
    enable = true;
    extraPackages = []; # I don't need foot etc bundled
  };
  programs.hyprland.enable = true;
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
  # cups for printing
  services.printing.enable = true;

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
  system.stateVersion = "23.11"; # Did you read the comment?
}
