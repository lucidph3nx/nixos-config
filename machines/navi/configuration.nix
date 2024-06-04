{
  pkgs,
  nixpkgs-stable,
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import ./disko.nix {device = "/dev/sdb";})
    inputs.disko.nixosModules.default
    ../../modules/nix
  ];

  nixModules = {
    sops = {
      generalSecrets.enable = true;
      signingKeys.enable = true;
      homeSSHKeys.enable = true;
      workSSH.enable = true;
      kubeconfig.enable = true;
    };
    syncthing = {
      enable = true;
      obsidian.enable = true;
      music.enable = true;
    };
    input-remapper.enable = true;
    # should be on home network
    nfs-mounts.enable = true;
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

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
      "/var/cache/tuigreet" # for remembering last user with tuigreet
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
    mkdir -p /persist/home/ben/.local/share/Steam
    chown -R ben:users /persist/home/ben
  '';

  networking = {
    hostName = "navi";
    networkmanager.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    hosts = {
    };
  };
  # allow portforward of 443
  security.wrappers = {
    ssh = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_bind_service=+eip";
      source = "${pkgs.openssh}/bin/ssh";
    };
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
      inherit nixpkgs-stable;
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
  environment.systemPackages = with pkgs; [
    awscli2
    chromium
    exfat 
    lsof
    ntfs3g
    p7zip
    parted
    protontricks
    protonup
    qpwgraph
    ssm-session-manager-plugin
  ];
hardware.openrazer = {
  enable = true;
  batteryNotifier = {
    enable = true;
    frequency = 60; #for testing
    percentage = 90;  #for testing
  };
};

  environment.sessionVariables = {
    # for kube
    KUBECONFIG = "${config.sops.secrets.homekube.path}";
  };

  fonts.fontDir.enable = true;
  fonts.packages = [
    (pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})
    pkgs.noto-fonts
  ];

  programs.zsh.enable = true;
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
  # display manager
  services.greetd = {
    enable = true;
    restart = true;
    package = pkgs.greetd.tuigreet;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --time-format '%Y-%m-%d %H:%M:%S' --cmd Hyprland";
        user = "greeter";
      };
    };
  };
  # sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };
  security.rtkit.enable = true;

  # cups for printing
  services.printing.enable = true;

  # gaming
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  services.xserver.videoDrivers = ["amdgpu"];
  programs.steam = {
    enable = true;
    gamescopeSession.enable = false;
  };
  programs.gamemode.enable = true;
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ben/.steam/root/compatibilitytools.d";
  };

  # experimental shutdown systemd service
  # trying to prevent force shutdowns of tmux
  systemd.services.shutdown-script = {
    enable = true;
    description = "Shutdown script";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStop = ''
        ${pkgs.tmux}/bin/tmux kill-server";
      '';
    };
  };

  # device specific syncthing config
  sops.secrets.navi-cert-pem = {
    owner = "ben";
    mode = "0600";
    sopsFile = ../../secrets/syncthingKeys.yaml;
  };
  sops.secrets.navi-key-pem = {
    owner = "ben";
    mode = "0600";
    sopsFile = ../../secrets/syncthingKeys.yaml;
  };
  services.syncthing.cert = config.sops.secrets.navi-cert-pem.path;
  services.syncthing.key = config.sops.secrets.navi-key-pem.path;

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
