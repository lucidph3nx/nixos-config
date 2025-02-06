{lib, ...}: {
  imports = [
    ./homeAutomation.nix
  ];

  homeManagerModules = {
    homeAutomation.enable = lib.mkDefault false;
  };
}
