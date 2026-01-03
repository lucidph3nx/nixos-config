{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    nx.programs.chromium.enable = lib.mkEnableOption "enables chromium" // {
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
      wayland.windowManager.hyprland.settings =
        lib.mkIf (config.home-manager.users.ben.wayland.windowManager.hyprland.enable)
          {
            windowrulev2 = [
              # sometimes chromium thinks its fine to open in a tiny window
              "tile on, match:class Chromium-browser"
            ];
          };
    };
  };
}
