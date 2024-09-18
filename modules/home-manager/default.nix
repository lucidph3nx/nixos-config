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
  ];
  config = {
    homeManagerModules = {
      desktopEnvironment.enable = lib.mkDefault true;
      firefox.enable = lib.mkDefault true;
      guiApps.enable = lib.mkDefault true;
      neovim.enable = lib.mkDefault true;
      sops.enable = lib.mkDefault false;
    };
    xdg.mimeApps.enable = true;
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
