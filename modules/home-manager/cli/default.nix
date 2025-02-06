{lib, ...}: {
  imports = [
    ./homeAutomation.nix
    ./zsh.nix
  ];

  homeManagerModules = {
    homeAutomation.enable = lib.mkDefault false;
    zsh.enable = lib.mkDefault true;
  };
}
