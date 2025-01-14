{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./additionalTheming.nix
    # ./ags # I'll come back to this oneday
    ./hyprland.nix
    ./hyprlock.nix
    ./input-remapper.nix
    ./mpd.nix
    ./pipewire-utils.nix
    ./rofi.nix
    ./screenshot.nix
    ./sway.nix
    ./swaylock.nix
    ./swaync.nix
    ./wallpaper.nix
    ./waybar.nix
  ];

  options = {
    homeManagerModules.desktopEnvironment.enable =
      lib.mkEnableOption "Enable Desktop Envrionment";
  };
  config =
    lib.mkIf (
      config.homeManagerModules.desktopEnvironment.enable
      && pkgs.stdenv.isLinux
    ) {
      homeManagerModules = {
        hyprland.enable = lib.mkDefault false;
        hyprlock.enable = lib.mkDefault false;
        input-remapper.enable = lib.mkDefault true;
        mpd.enable = lib.mkDefault true;
        pipewire-utils.enable = lib.mkDefault true;
        rofi.enable = lib.mkDefault true;
        sway.enable = lib.mkDefault true;
        swaylock.enable = lib.mkDefault true;
        swaync.enable = lib.mkDefault true;
        waybar = {
          enable = lib.mkDefault true;
          mouseBattery = lib.mkDefault false;
        };
      };
      home.packages = with pkgs; [
        wtype
      ];
    };
}
