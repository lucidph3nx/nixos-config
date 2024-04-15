{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./rofi.nix
    ./sway.nix
    ./swaync.nix
    ./waybar.nix
  ];

  options = {
    desktopEnvironment.enable =
      lib.mkEnableOption "Enable Desktop Envrionment";
  };
  config = lib.mkIf config.desktopEnvironment.enable {
    home-manager-modules = {
      sway.enable = lib.mkDefault true;
      swaync.enable = lib.mkDefault true;
      rofi.enable = lib.mkDefault true;
      waybar.enable = lib.mkDefault true;
    };
  };
}
