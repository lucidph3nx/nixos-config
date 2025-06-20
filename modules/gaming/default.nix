{
  lib,
  config,
  ...
}: {
  imports = [
    ./lutris.nix
    ./prismlauncher.nix
    ./steam.nix
    ./yuzu.nix
  ];
  options = {
    nx.gaming.enable =
      lib.mkEnableOption "enables gaming related modules"
      // {
        default = false;
      };
  };
  config = lib.mkIf config.nx.gaming.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    programs.gamemode.enable = true;
    home-manager.users.ben = {
      home.persistence."/persist/home/ben" = {
        directories = [
          ".local/share/vulkan"
        ];
      };
    };
  };
}
