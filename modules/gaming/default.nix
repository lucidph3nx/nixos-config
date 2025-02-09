{
  lib,
  config,
  ...
}: {
  imports = [
    ./prismlauncher.nix
    ./lutris.nix
  ];
  options = {
    nx.gaming.enable =
      lib.mkEnableOption "enables gaming related modules"
      // {
        default = false;
      };
  };
  config = lib.mkIf config.nx.gaming.enable {
    home-manager.users.ben = {
      home.persistence."/persist/home/ben" = {
        directories = [
          ".local/share/vulkan"
        ];
      };
    };
  };
}
