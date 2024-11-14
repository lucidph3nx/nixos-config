{
  config,
  lib,
  ...
}: let
  homeDir = config.home.homeDirectory;
  theme = config.theme;
in {
  options = {
    homeManagerModules.hyprlock.enable =
      lib.mkEnableOption "enables hyprlock";
    homeManagerModules.hyprlock.oled =
      lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable OLED specific settings";
      };
  };
  config = lib.mkIf config.homeManagerModules.hyprlock.enable {
    programs.hyprlock = let
      oled = config.homeManagerModules.hyprlock.oled;
      in {
      enable = true;
      settings = {
        hide_cursor = true;
        no_fade_in = true;
        no_fade_out = true;
        background = [
          {
            monitor = "";
            path = (lib.mkIf (oled == false) "${homeDir}/.config/wallpaper_${theme.name}.png");
            color = (lib.mkIf (oled == true) "rgba(0,0,0,1)");
            blur_passes = 0;
          }
        ];
        label = [
          {
            monitor = "";
            text = ''cmd[update:1000] echo $(date +'%T')'';
            color = "rgba(${builtins.substring 1 6 (theme.foreground)}ff)";
            font_size = 95;
            font_family = "JetBrains Mono";
            position = "0, 100";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = ''cmd[update:1000] echo $(date +'%F')'';
            color = "rgba(${builtins.substring 1 6 (theme.foreground)}ff)";
            font_size = 22;
            font_family = "JetBrains Mono";
            position = "0, 0";
            halign = "center";
            valign = "center";
          }
        ];
        input-field = {
          monitor = "";
          size = "300,50";
          outline_thickness = 3;
          dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.35; # Scale of dots' absolute size, 0.0 - 1.0
          dots_center = false;
          outer_color = "rgba(${builtins.substring 1 6 (theme.bg1)}ff)";
          inner_color = "rgba(${builtins.substring 1 6 (theme.bg_dim)}ff)";
          font_color = "rgba(${builtins.substring 1 6 (theme.green)}ff)";
          fade_on_empty = false;
          rounding = 0;
          check_color = "rgba(${builtins.substring 1 6 (theme.bg_dim)}ff)";
          fail_color = "rgba(${builtins.substring 1 6 (theme.red)}ff)";
          placeholder_text = ''<i><span foreground="#${theme.foreground}">Input Password...</span></i>'';
          hide_input = false;
          position = "0, -100";
          halign = "center";
          valign = "center";
        };
      };
    };
  };
}
