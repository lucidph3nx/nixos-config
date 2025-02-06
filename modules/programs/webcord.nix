{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.webcord.enable =
      lib.mkEnableOption "enables webcord"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.programs.webcord.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        webcord
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/WebCord"
        ];
      };
      wayland.windowManager.hyprland.settings = lib.mkIf (config.home-manager.users.ben.wayland.windowManager.hyprland.enable) {
        windowrulev2 = [
          # silently open on workspace 2
          "workspace 2 silent,class:(WebCord)"
        ];
      };
    };
  };
}
