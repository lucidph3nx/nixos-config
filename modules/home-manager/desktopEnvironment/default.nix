{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./additionalTheming.nix
    ./mpd.nix
    ./rofi.nix
    ./sway.nix
    ./swaylock.nix
    ./swaync.nix
    ./waybar.nix
  ];

  options = {
    homeManagerModules.desktopEnvironment.enable =
      lib.mkEnableOption "Enable Desktop Envrionment";
  };
  config = lib.mkIf (
  config.homeManagerModules.desktopEnvironment.enable 
  && lib.mkIf pkgs.stdenv.isLinux) {
    homeManagerModules = {
      mpd.enable = lib.mkDefault true;
      rofi.enable = lib.mkDefault true;
      sway.enable = lib.mkDefault true;
      swaylock.enable = lib.mkDefault true;
      swaync.enable = lib.mkDefault true;
      waybar.enable = lib.mkDefault true;
    };
  };
}
