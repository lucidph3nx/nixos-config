{
  config,
  pkgs,
  inputs,
  ...
}: {
  services.spacebar = {
    enable = true;
    package = pkgs.spacebar;
    config = {
      title = "off";
      clock = "on";
      foreground_color = "0xffd3c6aa";
      background_color = "0xff2d353b";
      clock_format = ''"%Y-%m-%d %H:%M:%S"'';
      clock_icon = "XX";
      clock_icon_color = "0xff2d353b";
      display_separator = "on";
      display_separator_icon = "|";
      space_icon_strip = "1 2 3 4 5 6 7 8 9 0";
      space_icon_color = "0xffa7c080";
      space_icon_color_secondary = "0xffdbbc7f";
      space_icon_color_tertiary = "0xff7fbbb3";
      spaces_for_all_displays = "on";
      power = "on";
      power_icon_strip = "󰁹 󰚥";
      power_icon_color = "0xffe69875";
      battery_icon_color = "0xffe69875";
      position = "top";
      text_font = ''"JetBrains Mono:regular:16.0"'';
      icon_font = ''"JetBrains Mono:regular:16.0"'';
      height = 35;
    };
  };
}
