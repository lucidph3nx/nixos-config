{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.webcord.enable =
      lib.mkEnableOption "enables webcord";
  };
  config = lib.mkIf config.homeManagerModules.webcord.enable {
    home.packages = with pkgs; [
      webcord
    ];
    home.persistence."/persist/home/ben" = {
      directories = [
        ".config/WebCord"
      ];
    };
  };
}
