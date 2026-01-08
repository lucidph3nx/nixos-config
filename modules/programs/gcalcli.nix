{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    nx.programs.gcalcli.enable = lib.mkEnableOption "enables gcalcli" // {
      default = false;
    };
  };
  config = lib.mkIf config.nx.programs.gcalcli.enable {
    home-manager.users.ben = {
      home.packages = [
        pkgs.gcalcli
      ];
      home.persistence."/persist" = {
        directories = [
          ".local/share/gcalcli"
        ];
      };
    };
  };
}
