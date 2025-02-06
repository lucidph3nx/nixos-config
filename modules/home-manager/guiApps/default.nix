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
    ./kitty.nix
    ./picard.nix
    ./plexamp.nix
    ./signal.nix
    ./vimiv.nix
    ./webcord.nix
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
      kitty.enable = lib.mkDefault true;
      picard.enable = lib.mkDefault false;
      plexamp.enable = lib.mkDefault false;
      signal.enable = lib.mkDefault true;
      vimiv.enable = lib.mkDefault true;
      webcord.enable = lib.mkDefault true;
    };
  };
}
