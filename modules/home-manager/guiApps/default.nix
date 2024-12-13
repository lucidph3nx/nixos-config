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
    ./kitty.nix
    ./libreoffice.nix
    ./mpv.nix
    ./obsidian.nix
    ./picard.nix
    ./plexamp.nix
    ./qutebrowser.nix
    ./vimiv.nix
    ./webcord.nix
    ./zathura.nix
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
      kitty.enable = lib.mkDefault true;
      libreoffice.enable = lib.mkDefault false;
      mpv.enable = lib.mkDefault true;
      obsidian.enable = lib.mkDefault false;
      picard.enable = lib.mkDefault false;
      plexamp.enable = lib.mkDefault false;
      vimiv.enable = lib.mkDefault true;
      webcord.enable = lib.mkDefault true;
      zathura.enable = lib.mkDefault true;
    };
  };
}
