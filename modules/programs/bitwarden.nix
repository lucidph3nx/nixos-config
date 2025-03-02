{
  config,
  pkgs,
  pkgs-stable,
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
        # https://github.com/nixos/nixpkgs/issues/380227
        pkgs-stable.bitwarden-cli
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/Bitwarden"
          ".config/Bitwarden CLI"
        ];
      };
      # force wayland
      xdg.desktopEntries.bitwarden = {
        name = "bitwarden";
        comment = "Secure and free password manager for all of your devices";
        icon = "bitwarden";
        exec = "bitwarden --enable-features=UseOzonePlatform --ozone-platform=wayland";
        mimeTypes = [ "x-scheme-handler/bitwarden" ];
      };
    };
  };
}
