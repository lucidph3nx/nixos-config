{ pkgs, lib, ... }: {
  imports = [
    ./guiApps
    ./cli
  ];
  guiApps.enable = lib.mkDefault true;
}
