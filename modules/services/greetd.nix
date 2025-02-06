{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.greetd.enable =
      lib.mkEnableOption "Add greetd/tuigreet setup"
      // {
        default = true;
      };
    nx.greetd.command = lib.mkOption {
      type = lib.types.str;
      default = "Hyprland";
      description = "Command to run as default session in greetd";
    };
  };
  config = lib.mkIf config.nx.greetd.enable {
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
      vt = 7; # the tty to run greetd on, changed so that systemd startup doesnt overwrite tuigreet
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --time-format '%Y-%m-%d %H:%M:%S' --cmd ${config.nx.greetd.command}";
          user = "greeter";
        };
      };
    };
  };
}
