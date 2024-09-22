{
  config,
  lib,
  ...
}: {
  options = {
    nixModules.sops.wireless.enable =
      lib.mkEnableOption "wireless configuration";
  };
  config = lib.mkIf config.nixModules.sops.wireless.enable {
    sops.secrets.wireless = {
      format = "binary";
      owner = "ben";
      mode = "0600";
      sopsFile = ../../../secrets/networkmanagerenv;
    };
  };
}
