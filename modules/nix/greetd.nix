{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nixModules.greetd.enable =
      lib.mkEnableOption "Add greetd/tuigreet setup";
  };
  config = lib.mkIf config.nixModules.greetd.enable {
    environment.persistence."/persist/system" = {
      hideMounts = true;
      directories = [
        "/var/cache/tuigreet" # for remembering last user with tuigreet
      ];
    };
    services.greetd = {
      enable = true;
      restart = true;
      package = pkgs.greetd.tuigreet;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --time-format '%Y-%m-%d %H:%M:%S' --cmd sway";
          user = "greeter";
        };
      };
    };
  };
}
