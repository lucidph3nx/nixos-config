{ pkgs, lib, ... }: {
  imports = [
    ./guiApps
    ./cli
    ./desktopEnvironment
  ];
  guiApps.enable = lib.mkDefault true;
  desktopEnvironment.enable = lib.mkDefault true;
}
