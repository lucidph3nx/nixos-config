{ config, pkgs, lib, ... }:

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
# hide titlebar for macos
hide_window_decorations titlebar-only
window_margin_width 15
# no confirm on window close
confirm_os_window_close 0
background_opacity 1.0
# vim:ft=kitty
## name: everforest_dark
## author: Sainnhe Park
## license: MIT
## upstream: https://github.com/ewal/kitty-everforest/blob/master/themes/everforest_dark_medium.conf
## blurb: A green based color scheme designed to be warm and soft

foreground                      #d3c6aa
background                      #2d353b
selection_foreground            #9da9a0
selection_background            #543a48

cursor                          #d3c6aa
cursor_text_color               #343f44

url_color                       #7fbbb3

active_border_color             #a7c080
inactive_border_color           #56635f
bell_border_color               #e69875
visual_bell_color               none

wayland_titlebar_color          system
macos_titlebar_color            system

active_tab_background           #2d353b
active_tab_foreground           #d3c6aa
inactive_tab_background         #3d484d
inactive_tab_foreground         #9da9a0
tab_bar_background              #343f44
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

