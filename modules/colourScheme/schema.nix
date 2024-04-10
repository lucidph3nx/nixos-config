{ config, lib, pkgs, ... }:

# This modules is used to define the schema for a colour scheme
# It is then free to be used by all other modules

with lib;
{
  # defaults based on the GitHub light theme
  theme = {
    foreground = mkOption { default = "#24292f"; type = types.str; };
    red = mkOption { default = "#cf222e"; type = types.str; };
    orange = mkOption { default = "#fb8f44"; type = types.str; };
    yellow = mkOption { default = "#4d2d00"; type = types.str; };
    green = mkOption { default = "#116329"; type = types.str; };
    aqua = mkOption { default = "#1b7c83"; type = types.str; };
    blue = mkOption { default = "#0969da"; type = types.str; };
    purple = mkOption { default = "#8250df"; type = types.str; };
    grey0 = mkOption { default = "#6e7781"; type = types.str; };
    grey1 = mkOption { default = "#57606a"; type = types.str; };
    grey2 = mkOption { default = "#424a53"; type = types.str; };
    statusline1 = mkOption { default = "#0969da"; type = types.str; };
    statusline2 = mkOption { default = "#6e7781"; type = types.str; };
    statusline3 = mkOption { default = "#cf222e"; type = types.str; };
    bg_dim = mkOption { default = "#ffffff"; type = types.str; };
    bg0 = mkOption { default = "#ffffff"; type = types.str; };
    bg1 = mkOption { default = "#f6f8fa"; type = types.str; };
    bg2 = mkOption { default = "#eaeef2"; type = types.str; };
    bg3 = mkOption { default = "#d0d7de"; type = types.str; };
    bg4 = mkOption { default = "#afb8c1"; type = types.str; };
    bg5 = mkOption { default = "#afb8c1"; type = types.str; };
    bg_visual = mkOption { default = "#ddf4ff"; type = types.str; };
    bg_red = mkOption { default = "#ffebe9"; type = types.str; };
    bg_green = mkOption { default = "#dafbe1"; type = types.str; };
    bg_blue = mkOption { default = "#ddf4ff"; type = types.str; };
    bg_yellow = mkOption { default = "#fff8c5"; type = types.str; };
  };
}


