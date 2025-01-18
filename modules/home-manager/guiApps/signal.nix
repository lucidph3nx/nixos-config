{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.signal.enable =
      lib.mkEnableOption "enables signal-desktop";
  };
  config = lib.mkIf config.homeManagerModules.signal.enable {
    home.packages = with pkgs; [
      signal-desktop
    ];
  #   home.persistence."/persist/home/ben" = {
  #     directories = [
  #       ".config/Plexamp"
  #     ];
  #   };
  };
}
