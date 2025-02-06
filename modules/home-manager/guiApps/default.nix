{
  config,
  lib,
  ...
}: {
  imports = [
    ./anki.nix
  ];

  options = {
    homeManagerModules.guiApps.enable =
      lib.mkEnableOption "Enable GUI applications";
  };
  config = lib.mkIf config.homeManagerModules.guiApps.enable {
    homeManagerModules = {
      anki.enable = lib.mkDefault false;
    };
  };
}
