{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    nx.programs.gimp.enable = lib.mkEnableOption "enables gimp" // {
      default = true;
    };
  };
  config = lib.mkIf config.nx.programs.gimp.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        gimp
      ];
    };
  };
}
