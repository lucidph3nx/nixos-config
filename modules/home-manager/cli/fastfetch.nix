{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.fastfetch.enable =
      lib.mkEnableOption "enables fastfetch" // {default = true;};
  };
  config = lib.mkIf config.homeManagerModules.kubetools.enable {
    home.packages = with pkgs; [
      fastfetch
    ];
    programs.fastfetch = {
      enable = true;
      settings = {
        modules = [
          "title"
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "display"
          "de"
          "wm"
          "wmtheme"
          "theme"
          "icons"
          "font"
          "cursor"
          "terminal"
          "terminalfont"
          "cpu"
          "gpu"
          "memory"
          "swap"
          "disk"
          "localip"
          "battery"
          "poweradapter"
          "locale"
          "break"
          "colors"
        ]
      };
    };
    programs.zsh.shellAliases = {
      ff = "fastfetch";
    };
  };
}
