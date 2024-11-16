{
  pkgs,
  lib,
  ...
}: {
  # change themes here
  imports = [
    # ./everforest.nix
    ./onedark.nix
    # ./github-light.nix
  ];
}
