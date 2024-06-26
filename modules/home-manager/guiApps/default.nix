{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./calibre.nix
    ./dragon-drop.nix
    ./kitty.nix
    ./libreoffice.nix
    ./mpv.nix
    ./obsidian.nix
    ./prospect-mail.nix
    ./teams-for-linux.nix
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
      calibre.enable = lib.mkDefault false;
      dragon-drop.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault true;
      libreoffice.enable = lib.mkDefault false;
      mpv.enable = lib.mkDefault true;
      obsidian.enable = lib.mkDefault false;
      prospect-mail.enable = lib.mkDefault false;
      teams-for-linux.enable = lib.mkDefault false;
      vimiv.enable = lib.mkDefault true;
      webcord.enable = lib.mkDefault true;
      zathura.enable = lib.mkDefault true;
    };
  };
}
