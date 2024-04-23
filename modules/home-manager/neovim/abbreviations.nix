{ config, lib, pkgs, inputs, ... }:

{
  # Setting my abbreviations
  programs.neovim = {
    extraConfig = 
      /*
      vim
      */
      ''
      ab ch - [ ]
      '';
  };
}
