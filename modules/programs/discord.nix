{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    nx.programs.discord.enable = lib.mkEnableOption "enables discord" // {
      default = true;
    };
  };
  config = lib.mkIf config.nx.programs.discord.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        discord
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/discord"
        ];
      };
      wayland.windowManager.hyprland.settings =
        lib.mkIf (config.home-manager.users.ben.wayland.windowManager.hyprland.enable)
          {
            windowrulev2 = [
              # silently open on workspace 2
              "class:(discord),workspace 2 silent"
            ];
          };
    };
  };
}
