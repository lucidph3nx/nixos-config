{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    nx.programs.signal.enable = lib.mkEnableOption "enables signal-desktop" // {
      default = true;
    };
  };
  config = lib.mkIf config.nx.programs.signal.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        signal-desktop
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/Signal"
        ];
      };
    };
  };
}
