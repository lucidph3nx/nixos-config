{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./firefox.nix
    ./kitty.nix
    ./zathura.nix
  ];

  options = {
    guiApps.enable =
      lib.mkEnableOption "Enable GUI applications";
  };
  config = lib.mkIf config.guiApps.enable {
    home-manager-modules = {
      firefox.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault true;
      zathura.enable = lib.mkDefault true;
    };
  };
}
