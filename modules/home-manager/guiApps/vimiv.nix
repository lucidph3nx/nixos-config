{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.vimiv.enable =
      lib.mkEnableOption "enables vimiv";
  };
  config = lib.mkIf config.homeManagerModules.vimiv.enable {
    home.packages = with pkgs; [
      vimiv-qt
    ];
  };
}
