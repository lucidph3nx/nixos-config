# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel" "v4l2loopback"];
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 max_buffers=2 video_nr=9 card_label=a6400
  '';
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # create the folder for the steam mount and make sure its chowned
  system.activationScripts.steamMountSetup = ''
    mkdir -p /home/ben/.local/share
    chown -R ben:users /home/ben/.local
  '';
  # mount other drives
  # nvme drive for steam
  fileSystems."/home/ben/.local/share/Steam" = {
    device = "/dev/disk/by-uuid/7983ec6a-00d7-44cb-8a0a-d801ec32a6fe";
    fsType = "ext4";
    options = [
      "auto"
      "x-systemd.requires-mounts-for=/persist/home/ben"
      "X-mount.owner=ben"
      "X-mount.group=users"
      "X-fstrim.notrim"
      "x-gvfs-hide"
    ];
  };
  # ssd for music
  fileSystems."/home/ben/music" = {
    device = "/dev/disk/by-uuid/04e6d89a-9c98-413b-88d5-95c586586990";
    fsType = "ext4";
    options = [
      "auto"
      "x-systemd.requires-mounts-for=/persist/home/ben"
      "X-mount.owner=ben"
      "X-mount.group=users"
      "X-fstrim.notrim"
      "x-gvfs-hide"
    ];
  };
}
