{ config, pkgs, lib, ... }:

with config.theme;
{
  options = {
    home-manager-modules.kitty.enable =
      lib.mkEnableOption "enables kitty";
  };
  config = lib.mkIf config.home-manager-modules.kitty.enable {
  programs.kitty = {
  	enable = true;
    font = {
      name = "JetBrainsMono Nerd Font Medium";
      size = 12.0;
    };
    extraConfig = ''
hide_window_decorations titlebar-only
window_margin_width 15
confirm_os_window_close 0
background_opacity 1.0

foreground                      ${foreground}
background                      ${bg0}
selection_foreground            ${grey2}
selection_background            ${bg_visual}

cursor                          ${foreground}
cursor_text_color               ${bg1}

url_color                       ${blue}

active_border_color             ${green}
inactive_border_color           ${bg5}
bell_border_color               ${orange}
visual_bell_color               none

wayland_titlebar_color          system
macos_titlebar_color            system

active_tab_background           ${bg0}
active_tab_foreground           ${foreground}
inactive_tab_background         ${bg2}
inactive_tab_foreground         ${grey2}
tab_bar_background              ${bg1}
tab_bar_margin_color            none

mark1_foreground                #2d353b
mark1_background                #7fbbb3
mark2_foreground                #2d353b
mark2_background                #d3c6aa
mark3_foreground                #2d353b
mark3_background                #d699b6

#: black
color0                          #343f44
color8                          #3d484d

#: red
color1                          #e67e80
color9                          #e67e80

#: green
color2                          #a7c080
color10                         #a7c080

#: yellow
color3                          #dbbc7f
color11                         #dbbc7f

#: blue
color4                          #7fbbb3
color12                         #7fbbb3

#: magenta
color5                          #d699b6
color13                         #d699b6

#: cyan
color6                          #83c092
color14                         #83c092

#: white
color7                          #859289
color15                         #9da9a0
    '';
  };
  };
}

