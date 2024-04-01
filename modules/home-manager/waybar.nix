{ config, pkgs, ... }:

{
  home.file = {
    ".config/waybar/config".source            = ./files/waybar-config;
    ".config/waybar/style.css".source         = ./files/waybar-style;
  };
}
