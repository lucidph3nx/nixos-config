{
  config,
  lib,
  ...
}:
with config.theme;
{
  options = {
    nx.programs.zathura.enable = lib.mkEnableOption "enables zathura" // {
      default = true;
    };
  };
  config = lib.mkIf config.nx.programs.zathura.enable {
    home-manager.users.ben = {
      programs.zathura = {
        enable = true;
        options = {
          selection-clipboard = "clipboard";
          default-bg = "${bg_dim}";
          default-fg = "${foreground}";
        };
      };
      xdg.mimeApps.defaultApplications = {
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      };
    };
  };
}
