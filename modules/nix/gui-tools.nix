{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.gui-tools.enable =
      lib.mkEnableOption "Add default gui tools"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.gui-tools.enable {
    environment.systemPackages = with pkgs; [
      (chromium.override {
        commandLineArgs = [
          "--enable-features=UseOzonePlatform"
          "--ozone-platform=wayland"
        ];
      })
    ];
  };
}
