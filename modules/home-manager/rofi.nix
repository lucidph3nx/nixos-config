{ config, pkgs, ... }:

{
  programs.rofi = {
  	enable = true;
    font = "JetBrainsMono Nerd Font Medium";
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
    ];
    extraConfig = {
      modi = "run,drun,emoji,calc";
      steal-focus = true;
      show-icons = true;
      icon-theme = "Papirus-Dark";
      application-fallback-icon = "run-build";
      drun-display-format = "{icon} {name}";
      matching = "fuzzy";
      scroll-method = 0;
      disable-history = false;
      display-drun = "";
      display-windows = "Windows:";
      display-run = " ";
      sort = true;
      sorting-method = "fzf";
    };
    theme = "~/.config/rofi/theme.rasi";
  };
  home.file.".config/rofi/theme.rasi".source = ./files/rofi-style;
  home.file.".config/rofi-emoji/custom_emoji_list.txt".source = ./files/rofi-custom-emoji-list;
}
