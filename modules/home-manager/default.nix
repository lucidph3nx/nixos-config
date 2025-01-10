{
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.defaultBrowser = lib.mkOption {
      default = "qutebrowser";
      type = lib.types.enum ["firefox" "qutebrowser"];
    };
  };
  imports = [
    ./cli
    ./desktopEnvironment
    ./firefox
    ./guiApps
    ./neovim
    ./qutebrowser
    ./scripts
    ./sshConfig
  ];
  config = {
    homeManagerModules = {
      desktopEnvironment.enable = lib.mkDefault true;
      firefox.enable = lib.mkDefault true;
      guiApps.enable = lib.mkDefault true;
      neovim.enable = lib.mkDefault true;
    };
    xdg.mimeApps.enable = true;
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
