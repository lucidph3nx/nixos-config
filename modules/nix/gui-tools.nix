{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nixModules.gui-tools.enable =
      lib.mkEnableOption "Add default gui tools";
  };
  config = lib.mkIf config.nixModules.gui-tools.enable {
    environment.systemPackages = with pkgs; [
      chromium
    ];
  };
}