{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    nx.gaming.mednafen.enable = lib.mkEnableOption "enables mednafen, a multi-system emulator" // {
      default = false;
    };
  };
  config =
    lib.mkIf
      (
        config.nx.gaming.mednafen.enable
        # only enable if gaming is enabled
        && config.nx.gaming.enable
      )
      {
        home-manager.users.ben = {
          home.packages = with pkgs; [
            mednafen
          ];
          home.sessionVariables = {
            MEDNAFEN_HOME = "${config.xdg.configHome}/mednafen";
          };
          home.persistence."/persist/home/ben" = {
            directories = [
              ".config/mednafen"
            ];
          };
        };
      };
}
