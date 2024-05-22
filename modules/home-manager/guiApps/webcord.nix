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
    home.pkgs = with pkgs; [
      webcord
    ];
  };
}
