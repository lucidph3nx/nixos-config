{ pkgs, lib, ... }: {
  imports = [
    ./k9s.nix
  ];
  home-manager-modules.k9s.enable = lib.mkDefault true;
}
