{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.webcord.enable =
      lib.mkEnableOption "enables webcord";
  };
  config = lib.mkIf config.homeManagerModules.webcord.enable {
    home.packages = with pkgs; [
      webcord
    ];
    home.persistence."/persist/home/ben" = {
      directories = [
        ".config/WebCord"
      ];
    };
    wayland.windowManager.hyprland.settings = lib.mkIf (config.homeManagerModules.hyprland.enable) {
      windowrulev2 = [
        # silently open on workspace 2
        "workspace 2 silent,class:(WebCord)"
      ];
    };
  };
}
