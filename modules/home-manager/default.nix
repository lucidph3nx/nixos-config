{ pkgs, lib, ... }: {
  imports = [
    ./cli
    ./desktopEnvironment
    ./guiApps
    ./sshConfig
    ./sops
  ];
  config = {
    homeManagerModules = {
      guiApps.enable = lib.mkDefault true;
      desktopEnvironment.enable = lib.mkDefault true;
      sops.enable = lib.mkDefault false;
    };
  };
}
