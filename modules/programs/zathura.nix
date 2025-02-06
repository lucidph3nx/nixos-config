{
  config,
  lib,
  ...
}: {
  options = {
    nx.programs.zathura.enable =
      lib.mkEnableOption "enables zathura"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.programs.zathura.enable {
    home-manager.users.ben = {
      programs.zathura = {
        enable = true;
      };
      xdg.mimeApps.defaultApplications = {
        "application/pdf" = ["org.pwmt.zathura.desktop"];
      };
    };
  };
}
