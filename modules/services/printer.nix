{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.printer.enable =
      lib.mkEnableOption "Configuration to support printer"
      // {
        default = false;
      };
  };
  config = lib.mkIf config.nx.printer.enable {
    # cups for printing
    services.printing = {
      enable = true;
      drivers = [
        # Brother laser printer driver
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
