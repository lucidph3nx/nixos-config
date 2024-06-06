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
      config = {
        osc = "no";
      };
      scripts = with pkgs.mpvScripts; [
        (lib.mkIf pkgs.stdenv.isLinux mpris)
        thumbnail
        sponsorblock
      ];
    };
  };
}
