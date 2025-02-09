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
    ../../modules
  ];

  nx = {
    desktop = {
      # hyprland doesnt work well in a vm
      hyprland.enable = false;
      sway.enable = true;
    };
    services = {
      syncthing = {
        enable = true;
        obsidian.enable = true;
        music.enable = false; # too large for a vm
      };
      greetd.command = "sway";
    };
    programs = {
      obsidian.enable = true;
      homeAutomation.enable = true;
    };
  };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  networking.hostName = "default"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
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
      ];
    };
  };

  # List services that you want to enable:
  services.dbus.implementation = "broker";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
