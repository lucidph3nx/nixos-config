{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.bitwardencli.enable =
      lib.mkEnableOption "enables bitwardencli";
  };
  config = lib.mkIf config.homeManagerModules.bitwardencli.enable {
    home.packages = with pkgs; [
      bitwarden-cli
    ];
    home.persistence."/persist/home/ben" = {
      directories = [
        ".config/Bitwarden CLI"
      ];
    };
  };
}
