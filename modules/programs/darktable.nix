{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    nx.programs.darktable.enable = lib.mkEnableOption "enables darktable" // {
      default = false;
    };
  };
  config = lib.mkIf config.nx.programs.darktable.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        darktable
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/darktable"
        ];
      };
      wayland.windowManager.hyprland.settings =
        lib.mkIf (config.home-manager.users.ben.wayland.windowManager.hyprland.enable)
          {
            windowrulev2 = [
              # darktable splash screen
              "title:darktable starting,float"
              # prevent darktable from maximising on start
              "class:(darktable),suppressevent maximize"
            ];
          };
    };
  };
}
