{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.plexamp.enable =
      lib.mkEnableOption "enables plexamp";
  };
  config = lib.mkIf config.homeManagerModules.plexamp.enable {
    home.packages = with pkgs; [
      plexamp
    ];
    home.persistence."/persist/home/ben" = {
      directories = [
        ".config/Plexamp"
      ];
    };
  };
}
