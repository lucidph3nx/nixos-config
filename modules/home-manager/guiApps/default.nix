{
  config,
  lib,
  ...
}: {
  imports = [
    ./anki.nix
    ./calibre.nix
    ./darktable.nix
    ./dragon-drop.nix
  ];

  options = {
    homeManagerModules.guiApps.enable =
      lib.mkEnableOption "Enable GUI applications";
  };
  config = lib.mkIf config.homeManagerModules.guiApps.enable {
    homeManagerModules = {
      anki.enable = lib.mkDefault false;
      calibre.enable = lib.mkDefault false;
      darktable.enable = lib.mkDefault false;
      dragon-drop.enable = lib.mkDefault true;
    };
  };
}
