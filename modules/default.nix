{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./home-manager
    #   ./nix
    ./colourScheme
  ];
}
