{ config, pkgs, lib, ... }:
{
  options = {
    nixModules.input-remapper.enable =
      lib.mkEnableOption "Set up input-remapper nix module";
  };
  config = lib.mkIf config.nixModules.input-remapper.enable {
    services.input-remapper = {
      enable = true;
    };
  };
}
