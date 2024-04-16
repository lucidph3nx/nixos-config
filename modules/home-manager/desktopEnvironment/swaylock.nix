
{ config, pkgs, lib, ... }:

with config.theme;
{
  options = {
    homeManagerModules.swaylock.enable =
      lib.mkEnableOption "enables swaylock";
  };
  config = lib.mkIf config.homeManagerModules.swaylock.enable {
    programs.swaylock = {
      enable = true;
      settings = {
        color = "000000";
        font = "JetBrainsMono Nerd Font, monospace";
        font-size = 20;
        disable-caps-lock-text = true;
        indicator-caps-lock = true;
        ignore-empty-passwor = true;
        show-failed-attempts = true;
        line-uses-inside = true;
        indicator-radius = 70;
        indicator-thickness = 15;
        inside-color = "${blue}ff";
        inside-ver-color = "${blue}ff";
        inside-wrong-color = "${red}ff";
        inside-clear-color = "${green}ff";
        inside-caps-lock-color = "${yellow}ff";
        text-color = "${bg0}ff";
        text-clear-color = "${bg0}ff";
        text-ver-color = "${bg0}ff";
        text-wrong-color = "${bg0}ff";
        layout-bg-color = "${bg_dim}ff";
        layout-text-color = "${bg0}ff";
      };
    };
  };
}
