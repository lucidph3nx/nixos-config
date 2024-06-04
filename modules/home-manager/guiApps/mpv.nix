{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.mpv.enable =
      lib.mkEnableOption "enables mpv";
  };
  config = lib.mkIf config.homeManagerModules.mpv.enable {
    programs.mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        mpris
        thumbnail
        sponsorblock
      ];
    };
  };
}
