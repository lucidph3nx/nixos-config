{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.picard.enable =
      lib.mkEnableOption "enables picard";
  };
  config = lib.mkIf config.homeManagerModules.picard.enable {
    home.packages = with pkgs; [
      picard
    ];
    home.persistence."/persist/home/ben" = {
      directories = [
        ".config/MusicBrainz"
      ];
    };
  };
}
