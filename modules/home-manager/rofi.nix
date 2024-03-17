{ config, pkgs, ... }:

{
  programs.rofi = {
  	enable = true;
    font = "JetBrainsMono Nerd Font Medium";
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
    ];
  };
  home.file = {
    ".config/rofi/config.rasi".source = ./files/rofi-config;
    ".config/rofi/theme.rasi".source = ./files/rofi-style;
  };
}
