{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./additionalTheming.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./input-remapper.nix
    ./mpd.nix
    ./pipewire-utils.nix
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
      home.file.".config/wallpaper_everforest-1680x1050.png".source = ./files/wallpaper_everforest-1680x1050.png;
      home.file.".config/wallpaper_everforest-5120x1440.png".source = ./files/wallpaper_everforest-5120x1440.png;
      home.file.".config/wallpaper_github_light-5120x1440.png".source = ./files/wallpaper_github_light-5120x1440.png;
      home.file.".config/wallpaper_everforest-2880x1800.png".source = ./files/wallpaper_everforest-2880x1800.png;
      home.file.".config/wallpaper_github_light-2880x1800.png".source = ./files/wallpaper_github_light-2880x1800.png;
    };
}
