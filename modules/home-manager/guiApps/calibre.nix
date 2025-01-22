{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.calibre.enable =
      lib.mkEnableOption "enables calibre";
  };
  config = lib.mkIf config.homeManagerModules.calibre.enable {
    home.packages = [
      pkgs.calibre
    ];
    home.persistence."/persist/home/ben" = {
      directories = [
        ".config/calibre"
      ];
    };
  };
}
