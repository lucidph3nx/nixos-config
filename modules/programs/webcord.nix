{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    nx.programs.webcord.enable = lib.mkEnableOption "enables webcord" // {
      default = true;
    };
  };
  config = lib.mkIf config.nx.programs.webcord.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        # webcord
        # on 2025-11-11 webcord stopped building due to using an old electron version
        # so I've temporarily switched to discord
        discord
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/WebCord"
          ".config/discord"
        ];
      };
      wayland.windowManager.hyprland.settings =
        lib.mkIf (config.home-manager.users.ben.wayland.windowManager.hyprland.enable)
          {
            windowrulev2 = [
              # silently open on workspace 2
              "workspace 2 silent,class:(WebCord)"
            ];
          };
    };
  };
}
