{ config, pkgs, ... }:

{
  programs.kitty = {
  	enable = true;
    font = {
      name = "JetBrains Mono";
      size = 12.0;
    };
    extraConfig = ''
      # hide titlebar for macos
      hide_window_decorations titlebar-only
      window_margin_width 15
      # no confirm on window close
      confirm_os_window_close 0
      background_opacity 1.0
    '';
  };
}
