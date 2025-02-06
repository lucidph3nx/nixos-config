{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.bitwarden.enable =
      lib.mkEnableOption "enables bitwarden-desktop"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.programs.bitwarden.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        bitwarden-desktop
        bitwarden-cli
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/Bitwarden"
          ".config/Bitwarden CLI"
        ];
      };
    };
  };
}
