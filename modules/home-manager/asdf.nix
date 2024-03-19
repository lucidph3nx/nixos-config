{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.asdf-vm
  ];
  home.file.".tool-versions".text = ''
  nodejs 20.8.1
  terraform 1.3.6
  '';
  programs.zsh.initExtra = ''
    . $(dirname $(dirname $(readlink -f $(which asdf))))/share/asdf-vm/asdf.sh
  '';
}

