{ pkgs, lib, ... }: {
  imports = [
    ./cli
    ./desktopEnvironment
    ./guiApps
    # ./neovim
    ./sops
    ./sshConfig
  ];
  config = {
    homeManagerModules = {
      desktopEnvironment.enable = lib.mkDefault true;
      guiApps.enable = lib.mkDefault true;
      neovim.enable = lib.mkDefault true;
      sops.enable = lib.mkDefault false;
    };
  };
}
