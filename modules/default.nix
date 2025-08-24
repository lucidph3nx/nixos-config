{ config, lib, pkgs, ... }:
{
  imports = [
    ./colourScheme
    ./desktop
    ./gaming
    ./programs
    ./services
    ./system
  ];
  options = {
    nx.externalAudio.enable = lib.mkEnableOption {
      default = false;
      description = "machine is using external audio control, disable things like volume controls";
    };
    nx.deviceLocation = lib.mkOption {
      default = "none";
      description = "physical location of the machine, for showing local variables like temp humidity";
      type = lib.types.str;
    };
    nx.isLaptop = lib.mkEnableOption {
      default = false;
      description = "machine is a laptop, enable things like battery monitoring";
    };
  };
  config = {
    # Let Home Manager install and manage itself.
    home-manager.users.ben.programs.home-manager.enable = true;
  };
}
