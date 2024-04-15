{ pkgs, lib, ... }: {
  imports = [
    ./guiApps
    ./cli
    ./desktopEnvironment
  ];
  config = {
    homeManagerModules = {
      guiApps.enable = lib.mkDefault true;
      desktopEnvironment.enable = lib.mkDefault true;
    };
  };
}
