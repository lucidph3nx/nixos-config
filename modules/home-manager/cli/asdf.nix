{ config, pkgs, lib, ... }:

{
  options = {
    homeManagerModules.asdf.enable =
      lib.mkEnableOption "enables asdf";
  };
  config = lib.mkIf config.homeManagerModules.asdf.enable {
    home.packages = [
      pkgs.asdf-vm
    ];
    home.file.".tool-versions".text = ''
      nodejs 20.8.1
      terraform 1.3.6
    '';
    programs.zsh.initExtra = ''
      . ${pkgs.asdf-vm}/share/asdf-vm/asdf.sh
    '';
  };
}

