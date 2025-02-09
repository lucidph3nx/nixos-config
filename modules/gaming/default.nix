{lib, ...}: {
  imports = [
    ./prismlauncher.nix
  ];
  options = {
    nx.gaming.enable =
      lib.mkEnableOption "enables gaming related modules"
      // {
        default = false;
      };
  };
}
