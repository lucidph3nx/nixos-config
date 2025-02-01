{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nixModules.printer.enable =
      lib.mkEnableOption "Code to support printer"
      // {
        default = false;
      };
  };
  config = lib.mkIf config.nixModules.printer.enable {
    # cups for printing
    services.printing = {
      enable = true;
      drivers = [
        pkgs.brlaser
      ];
    };
    # printer autoddiscovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
