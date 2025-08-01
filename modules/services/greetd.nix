{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.services.greetd.enable =
      lib.mkEnableOption "Add greetd/tuigreet setup"
      // {
        default = true;
      };
    nx.services.greetd.command = lib.mkOption {
      type = lib.types.str;
      default = "Hyprland";
      description = "Command to run as default session in greetd";
    };
  };
  config = lib.mkIf config.nx.services.greetd.enable {
    environment.persistence."/persist/system" = {
      hideMounts = true;
      directories = [
        "/var/cache/tuigreet" # for remembering last user with tuigreet
      ];
    };
    services.greetd = {
      enable = true;
      restart = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --time-format '%Y-%m-%d %H:%M:%S' --cmd ${config.nx.services.greetd.command}";
          user = "greeter";
        };
      };
    };
  };
}
