{ pkgs, lib, ... }: {
  imports = [
    ./cli
    ./desktopEnvironment
    ./guiApps
    ./sshConfig
  ];
  config = {
    homeManagerModules = {
      guiApps.enable = lib.mkDefault true;
      desktopEnvironment.enable = lib.mkDefault true;
    };
  };
}
