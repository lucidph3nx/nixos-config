{ config, pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "kitty"; 
      startup = [
        # Launch kitty on start
        {command = "kitty";}
      ];
      bars = [
      	{command = "${pkgs.waybar}/bin/waybar";}
      ];
    };
  };
}
