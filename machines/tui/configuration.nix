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
    (import ./disko.nix {device = "/dev/nvme0n1";})
    inputs.disko.nixosModules.default
    ../../modules
  ];

  nx = {
    isLaptop = true;
    desktop = {
      theme = "onedark";
      hyprland = {
        lockTimeout.enable = false;
        screenTimeout.duration = 600; # screen off after 10 minutes
        suspendTimeout.duration = 900; # suspend after 15 minutes
      };
      hyprlock.oled = true;
      wallpaper = {
        variant = "enso";
        resolution = "2880x1800";
      };
      offline-focus-mode.enable = true;
    };
    programs = {
      calibre.enable = true;
      darktable.enable = true;
      firefox.hideUrlbar = true;
      homeAutomation.enable = true;
      libreoffice.enable = true;
      obsidian.enable = true;
      picard.enable = true;
      plexamp.enable = true;
    };
    services = {
      blocky.enable = false; # for roaming, slows startup at home
      syncthing = {
        enable = true;
        obsidian.enable = true;
        calibre.enable = true;
        music.enable = true;
        photos.enable = true;
      };
      printer.enable = true;
    };
    system = {
      nfs-mounts.enable = true;
      sops.ageKeys.enable = true;
    };
    gaming = {
      enable = true;
      prismlauncher.enable = true;
    };
  };

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "tui";

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
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cheese
    exfat
    ffmpeg
    gamescope
    inkscape
    mangohud
    ntfs3g
    parted
    protontricks
    protonup
    shotcut
    solvespace
    usbutils
    wev
  ];
  # key remapping
  services.keyd = {
    enable = true;
    keyboards = {
      main = {
        settings = {
          main = {
            capslock = "overload(control,esc)";
          };
        };
      };
      mouse = {
        ids = ["1532:00b7:aa6166ef"]; # Razer Deathadder V3 Pro
        settings = {
          main = {
            mouse1 = "volumedown";
            mouse2 = "volumeup";
          };
        };
      };
    };
  };

  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
