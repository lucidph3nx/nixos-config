{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.calibre.enable =
      lib.mkEnableOption "enables calibre";
  };
  config = lib.mkIf config.homeManagerModules.calibre.enable {
    home.packages = with pkgs; [
      calibre
    ];
  };
}
