{ pkgs, lib, ... }: {
  imports = [
    ./guiApps
    ./cli
    ./desktopEnvironment
  ];
  config = {
    home-manager-modules = {
      guiApps.enable = lib.mkDefault true;
      desktopEnvironment.enable = lib.mkDefault true;
    };
  };
}
