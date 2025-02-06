{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.obsidian.enable =
      lib.mkEnableOption "enables obsidian";
  };
  config = lib.mkIf config.nx.programs.obsidian.enable {
    home-manager.users.ben.home = {
      packages = with pkgs; [
        obsidian
      ];
      persistence."/persist/home/ben" = {
        directories = [
          ".config/obsidian"
        ];
      };
    };
  };
}
