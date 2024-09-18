{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.darktable.enable =
      lib.mkEnableOption "enables darktable";
  };
  config = lib.mkIf config.homeManagerModules.darktable.enable {
    home.packages = with pkgs; [
      darktable
    ];
    home.persistence."/persist/home/ben" = {
      directories = [
        "pictures/darktable"
        ".config/darktable"
      ];
    };
  };
}
