{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./everforest.nix
    ./onedark.nix
    ./github-light.nix
  ];
  options = {
    setTheme = lib.mkOption {
      default = "everforest";
      type = lib.types.enum ["everforest" "onedark" "github-light"];
    };
  };
}
