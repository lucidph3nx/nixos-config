{ pkgs, lib, ... }: {
  imports = [
    ./guiApps
    ./cli
    ./desktopEnvironment
  ];
  home-manager-modules.guiApps.enable = lib.mkDefault true;
  home-manager-modules.desktopEnvironment.enable = lib.mkDefault true;
}
