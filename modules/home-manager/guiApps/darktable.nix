{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.darktable.enable =
      lib.mkEnableOption "enables darktable";
  };
  config = lib.mkIf config.homeManagerModules.darktable.enable {
    home.packages = with pkgs; [
      darktable
    ];
    home.persistence."/persist/home/ben" = {
      directories = [
        "pictures/darktable"
        ".config/darktable"
      ];
    };
    wayland.windowManager.hyprland.settings = lib.mkIf (config.homeManagerModules.hyprland.enable) {
      windowrulev2 = [
        # darktable splash screen
        "float, title:darktable starting"
        # prevent darktable from maximising on start
        "suppressevent maximize, class:(darktable)"
      ];
    };
  };
}
