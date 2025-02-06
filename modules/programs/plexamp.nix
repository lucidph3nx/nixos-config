{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.plexamp.enable =
      lib.mkEnableOption "enables plexamp"
      // {
        default = false;
      };
  };
  config = lib.mkIf config.nx.programs.plexamp.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        plexamp
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/Plexamp"
        ];
      };
    };
  };
}
