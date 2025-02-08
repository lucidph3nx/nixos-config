{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.chromium.enable =
      lib.mkEnableOption "enables chromium"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.programs.chromium.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        (chromium.override {
          commandLineArgs = [
            "--enable-features=UseOzonePlatform"
            "--ozone-platform=wayland"
          ];
        })
      ];
    };
  };
}
