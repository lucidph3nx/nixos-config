{ config, lib, pkgs, ... }:

# This module is a schema for setting
# some high level system settings

with lib;
let
  systemDefaultsType = types.submodule {
    options = {
      terminal = mkOption {
        type = types.str; 
        example = "\${pkgs.alacritty}/bin/alacritty"; 
        description = ''
          the default terminal multiplexer
          to be used in any scripts or shortcuts
          where it is needed
        '';
        };
    };
  };
in
{
  options = {
    sysDefaults = mkOption {
      type = systemDefaultsType;
      default = {
        terminal = "";
      };
    };
  };
}


