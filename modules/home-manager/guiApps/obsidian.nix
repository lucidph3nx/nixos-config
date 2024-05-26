{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.obsidian.enable =
      lib.mkEnableOption "enables obsidian";
  };
  config = lib.mkIf config.homeManagerModules.obsidian.enable {
    home.packages = with pkgs; [
      obsidian
    ];
  };
}
