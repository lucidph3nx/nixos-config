{
  config,
  lib,
  ...
}: {
  imports = [
    ./anki.nix
    ./calibre.nix
    ./cura-appimage.nix
    ./darktable.nix
    ./dragon-drop.nix
    ./plexamp.nix
  ];

  options = {
    homeManagerModules.guiApps.enable =
      lib.mkEnableOption "Enable GUI applications";
  };
  config = lib.mkIf config.homeManagerModules.guiApps.enable {
    homeManagerModules = {
      anki.enable = lib.mkDefault false;
      calibre.enable = lib.mkDefault false;
      cura.enable = lib.mkDefault false;
      darktable.enable = lib.mkDefault false;
      dragon-drop.enable = lib.mkDefault true;
      plexamp.enable = lib.mkDefault false;
    };
  };
}
