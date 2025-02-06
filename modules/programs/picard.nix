{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.picard.enable =
      lib.mkEnableOption "enables picard"
      // {
        default = false;
      };
  };
  config = lib.mkIf config.nx.programs.picard.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        picard
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/MusicBrainz"
        ];
      };
    };
  };
}
