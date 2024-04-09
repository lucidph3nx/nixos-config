{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
  };
  home.file = {
    ".config/waybar/config".source            = ./files/waybar-config;
    ".config/waybar/style.css".source         = ./files/waybar-style;
  };
}
