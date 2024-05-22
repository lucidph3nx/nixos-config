{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nixModules.input-remapper.enable =
      lib.mkEnableOption "Set up input-remapper nix module";
  };
  config = lib.mkIf config.nixModules.input-remapper.enable {
    services.input-remapper = {
      enable = true;
    };
    security.sudo.extraConfig = ''
      ben ALL=(ALL) NOPASSWD: ${pkgs.input-remapper}/bin/input-remapper-control
    '';
    users.users.ben.extraGroups = ["input"];
  };
}
