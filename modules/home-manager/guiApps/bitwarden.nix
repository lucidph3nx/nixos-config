{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.bitwarden.enable =
      lib.mkEnableOption "enables bitwarden-desktop";
  };
  config = lib.mkIf config.homeManagerModules.bitwarden.enable {
    home.packages = with pkgs; [
      bitwarden-desktop
    ];
    home.persistence."/persist/home/ben" = {
      directories = [
        ".config/Bitwarden"
      ];
    };
  };
}
