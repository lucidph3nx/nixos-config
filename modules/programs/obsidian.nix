{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.obsidian.enable =
      lib.mkEnableOption "enables obsidian"
      // {
        default = false;
      };
  };
  config = lib.mkIf config.nx.programs.obsidian.enable {
    home-manager.users.ben = {
      home = {
        packages = with pkgs; [
          obsidian
        ];
        persistence."/persist/home/ben" = {
          directories = [
            ".config/obsidian"
          ];
        };
      };
      # force wayland
      xdg.desktopEntries.obsidian = {
        name = "Obsidian";
        comment = "Knowledge base";
        icon = "obsidian";
        exec = "obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland";
        mimeType = ["x-scheme-handler/obsidian"];
      };
    };
  };
}
