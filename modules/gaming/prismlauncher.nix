{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.gaming.prismlauncher.enable =
      lib.mkEnableOption "enables prismlauncher, open source minecraft launcher"
      // {
        default = false;
      };
  };
  config = lib.mkIf (config.nx.gaming.prismlauncher.enable
    # only enable if gaming is enabled
    && config.nx.gaming.enable) {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        prismlauncher
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".local/share/PrismLauncher"
        ];
      };
    };
  };
}
