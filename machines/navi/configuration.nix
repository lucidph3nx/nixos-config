{
  pkgs,
  pkgs-stable,
  pkgs-master,
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import ./disko.nix {device = "/dev/nvme1n1";})
    inputs.disko.nixosModules.default
    ../../modules/nix
  ];

  nixModules = {
    externalAudio.enable = true; # using external dac
    deviceLocation = "office";
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
      music = {
        enable = true;
        path = "/home/ben/music";
      };
    };
    input-remapper.enable = true;
    # should be on home network
    nfs-mounts.enable = true;
  };

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    # useOSProber = true; # no other boot partitions for now
  };

  # https://github.com/nix-community/impermanence/issues/229
  boot.initrd.systemd.suppressedUnits = ["systemd-machine-id-commit.service"];
  systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

  # Hardware switch - also disabled, no other boot partitions for now
  # boot.loader.grub.extraConfig =
  #   /*
  #   bash
  #   */
  #   ''
  #     # Look for hardware switch device by its hard-coded filesystem ID
  #     search --no-floppy --fs-uuid --set hdswitch 55AA-6922
  #     # If found, read dynamic config file and select appropriate entry for each position
  #     if [ "''${hdswitch}" ] ; then
  #       source ($hdswitch)/switch_position_grub.cfg
  #
  #       if [ "''${os_hw_switch}" == 0 ] ; then
  #         # Boot Linux
  #         set default=0
  #       elif [ "''${os_hw_switch}" == 1 ] ; then
  #         # Boot Windows
  #         set default=2
  #       fi
  #     fi
  #   '';

  # Wipe the disk on each boot
  boot.initrd.postDeviceCommands =
    lib.mkAfter
    /*
    bash
    */
    ''
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

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +14); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';
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

  networking = {
    hostName = "navi";
    networkmanager.enable = true;
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
    extraGroups = ["networkmanager" "wheel" "openrazer"];
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
  environment.systemPackages = with pkgs; [
    cheese
    exfat
    ffmpeg
    freetype # fonts needed for wine
    gamescope
    gphoto2
    lsof
    lutris-unwrapped
    mangohud
    ntfs3g
    parted
    polychromatic
    protontricks
    protonup
    qpwgraph
    shotcut
    solvespace
    usbutils
    v4l-utils
    wineWowPackages.waylandFull
  ];
  hardware.openrazer = {
    enable = true;
    # doesn't work, always sends notifications of 0%, probably the devices fault
    batteryNotifier.enable = false;
  };
  hardware.amdgpu.amdvlk = {
    enable = true;
    support32Bit.enable = true;
  };

  environment.sessionVariables = {
    # for kube
    KUBECONFIG = "${config.sops.secrets.homekube.path}";
  };

  fonts.fontDir.enable = true;
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.noto-fonts
  ];

  programs.sway = {
    enable = true;
    extraPackages = []; # I don't need foot etc bundled
  };
  programs.hyprland = {
    enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
    ];
    wlr.enable = lib.mkForce true; #TODO: figure out why hyprland conflicts with this
  };

  # List services that you want to enable:
  services.dbus.implementation = "broker";
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    wireplumber.extraConfig = {
      # 100% volume
      "10-default-volume" = {
        "wireplumber.settings"."device.routes.default-sink-volume" = 1.0;
      };
      # FiiO K7 as default sink
      "10-default-sink" = {
        "wireplumber.settings"."default.configured.audio.sink" = "alsa_output.usb-GuangZhou_FiiO_Electronics_Co._Ltd_FiiO_K7-00.analog-stereo";
      };
      # AT2020USB-XLR as default source
      "10-default-source" = {
        "wireplumber.settings"."default.configured.audio.source" = "alsa_input.usb-AT_AT2020USB-X_202011110001-00.mono-fallback";
      };
      "51-alsa-disable" = {
        "monitor.alsa.rules" = [
          {
            "matches" = [
              {
                # disable, not a output device
                "node.name" = "alsa_output.usb-AT_AT2020USB-X_202011110001-00.analog-stereo";
              }
              {
                # Bult in output disable, nothing plugged in
                "node.name" = "alsa_output.pci-0000_00_1f.3.iec958-stereo";
              }
              {
                # HDMI output disable, never used
                "node.name" = "alsa_output.pci-0000_03_00.1.hdmi-stereo-extra4";
              }
              {
                # disable, webcam should never be used for audio
                "node.name" = "alsa_input.usb-046d_Logitech_StreamCam_F2867D05-02.analog-stereo";
              }
              {
                # Bult in input disable, nothing plugged in
                "node.name" = "alsa_input.pci-0000_00_1f.3.analog-stereo";
              }
            ];
            "actions" = {
                "update-props" = {
                  "node.disabled" = true;
                };
            };
          }
        ];
      };
    };
  };
  security.rtkit.enable = true;

  # cups for printing
  services.printing.enable = true;

  # gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  programs.steam = {
    enable = true;
    gamescopeSession.enable = false;
    protontricks.enable = true;
  };
  programs.gamemode.enable = true;
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ben/.steam/root/compatibilitytools.d";
  };

  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
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

  # services.ollama = {
  #   enable = true;
  #   acceleration = "rocm";
  #   rocmOverrideGfx = "10.3.0";
  #   loadModels = [
  #     "llama3:latest"
  #   ];
  #   home = "/var/lib/ollama";
  # };
  # users.groups.ollama = {};
  # users.users.ollama = {
  #   group = "ollama";
  #   isSystemUser = true;
  # };
  # systemd.services.ollama.after = ["var-lib-ollama.mount"];

  virtualisation = {
    waydroid.enable = true;
    # libvirtd.enable = true;
  };
  # programs.virt-manager.enable = true;
  networking.firewall = {
    allowedTCPPorts = [
      6600 #mpd
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
