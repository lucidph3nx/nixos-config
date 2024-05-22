{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./cli
    ./desktopEnvironment
    ./firefox
    ./guiApps
    ./neovim
    ./scripts
    ./sops
    ./sshConfig
    ./syncthing.nix
  ];
  config = {
    homeManagerModules = {
      desktopEnvironment.enable = lib.mkDefault true;
      firefox.enable = lib.mkDefault true;
      guiApps.enable = lib.mkDefault true;
      neovim.enable = lib.mkDefault true;
      sops.enable = lib.mkDefault false;
      syncthing.enable = lib.mkDefault true;
    };
  };
}
