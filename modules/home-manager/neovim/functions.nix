{ config, lib, pkgs, inputs, ... }:

{
  # some lua functions that don't escape well
  programs.neovim = {
    extraLuaConfig = builtins.toFile ./functions.lua '';
  };
}
