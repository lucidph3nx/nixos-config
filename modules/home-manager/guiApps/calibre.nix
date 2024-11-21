{
  config,
  pkgs,
  pkgs-master,
  lib,
  ...
}: {
  options = {
    homeManagerModules.calibre.enable =
      lib.mkEnableOption "enables calibre";
  };
  config = lib.mkIf config.homeManagerModules.calibre.enable {
    home.packages = [
      # waiting for https://nixpk.gs/pr-tracker.html?pr=355885
      pkgs-master.calibre
    ];
    home.persistence."/persist/home/ben" = {
      directories = [
        ".config/calibre"
      ];
    };
  };
}
