{ pkgs, lib, ... }: {
  imports = [
    ./gui
    ./cli
  ];
  guiApps.enable = lib.mkDefault true;
}
