{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.anki.enable =
      lib.mkEnableOption "enables anki";
  };
  config = lib.mkIf config.homeManagerModules.anki.enable {
    home.packages = with pkgs; [
      anki
    ];
    home.persistence."/persist/home/ben" = {
      directories = [
        ".local/share/Anki2"
      ];
    };
  };
}
