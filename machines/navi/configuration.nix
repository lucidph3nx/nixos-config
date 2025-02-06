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
    ../../modules
  ];

  nx = {
    externalAudio.enable = true; # using external dac
    deviceLocation = "office";
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
        music = {
          enable = true;
          path = "/home/ben/music";
        };
      };
      printer.enable = true;
    };
    programs = {
      anki.enable = true;
      calibre.enable = true;
      cura.enable = true;
      darktable.enable = true;
      libreoffice.enable = true;
      obsidian.enable = true;
      picard.enable = true;
      plexamp.enable = true;
    };
    # should be on home network
    nfs-mounts.enable = true;
  };

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking = {
    hostName = "navi";
    networkmanager.enable = true;
  };

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
        ../../modules/home-manager
        ../../modules/colourScheme
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

  # key remapping
  services.keyd = {
    enable = true;
    keyboards = {
      mouse = {
        ids = ["1532:00b7:aa6166ef"]; # Razer Deathadder V3 Pro
        settings = {
          main = {
            mouse1 = "playpause";
            mouse2 = "leftmeta";
          };
        };
      };
    };
  };

  # List services that you want to enable:
  services.dbus.implementation = "broker";

  # sound
  services.pipewire.wireplumber.extraConfig = {
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
  security.rtkit.enable = true;

  # gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  programs.steam = {
    enable = true;
    gamescopeSession.enable = false;
    protontricks.enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          libcap
          procps
          usbutils
        ];
    };
  };
  # for vr headsets
  hardware.steam-hardware.enable = true;

  # IMPORTANT: for anyone who found this code by searching github, I do not have a working VR setup
  # not sure what I'm missing, but I'll try again later, don't treat this as a working example

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
