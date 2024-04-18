{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./firefox.nix
    ./kitty.nix
    ./zathura.nix
    ./prospect-mail.nix
    ./teams-for-linux.nix
  ];

  options = {
    homeManagerModules.guiApps.enable =
      lib.mkEnableOption "Enable GUI applications";
  };
  config = lib.mkIf config.homeManagerModules.guiApps.enable {
    homeManagerModules = {
      firefox.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault true;
      zathura.enable = lib.mkDefault true;
      prospect-mail.enable = lib.mkDefault false;
      teams-for-linux.enable = lib.mkDefault false;
    };
  };
}
