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
    home.programs.mpv = {
      enable = true;
      package = pkgs.mpv;
      scripts = with pkgs.mpvScipts; [
        mpris
        thumbnail
        sponsorblock
      ];
    };
  };
}
