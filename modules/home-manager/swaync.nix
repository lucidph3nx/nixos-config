{ config, pkgs, ... }:

{
  home.file = {
    ".config/swaync/config.json".source = ./files/swaync-config;
    ".config/swaync/style.css".source   = ./files/swaync-style;
  };
}