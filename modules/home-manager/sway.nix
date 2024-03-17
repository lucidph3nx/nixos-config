{ config, pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
  };
  home.file = {
    ".config/sway/config".source              = ./files/sway-config;
    ".config/sway/navi/config".source         = ./files/sway-navi-config;
    ".config/sway/scripts/set_gaps.sh".source = ./files/sway-script-setgaps;
  };
}
