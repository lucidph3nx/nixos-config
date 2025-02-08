{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./rofi.nix
    ./swaync.nix
    ./wallpaper.nix
  ];

  options = {
    homeManagerModules.desktopEnvironment.enable =
      lib.mkEnableOption "Enable Desktop Envrionment";
  };
  config =
    lib.mkIf (
      config.homeManagerModules.desktopEnvironment.enable
      && pkgs.stdenv.isLinux
    ) {
      homeManagerModules = {
        rofi.enable = lib.mkDefault true;
        swaync.enable = lib.mkDefault true;
      };
      home.packages = with pkgs; [
        wtype
      ];
    };
}
