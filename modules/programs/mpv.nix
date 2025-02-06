{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.mpv.enable =
      lib.mkEnableOption "enables mpv"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.programs.mpv.enable {
    home-manager.users.ben = {
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
  };
}
