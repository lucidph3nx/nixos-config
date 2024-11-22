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
        logo = {
          source = "nixos";
          color = {
            "1" = "blue";
            "2" = "green";
          };
        };
        display = {
          color = {
            keys = "green";
            title = "blue";
          };
        };
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
          "wm"
          "cursor"
          "terminal"
          "terminalfont"
          "cpu"
          "gpu"
          "memory"
          "swap"
          "disk"
          "battery"
          "poweradapter"
          "locale"
          "break"
          "colors"
        ];
      };
    };
    programs.zsh.shellAliases = {
      ff = "fastfetch";
    };
  };
}
