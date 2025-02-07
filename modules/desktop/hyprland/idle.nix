{
  config,
  lib,
  ...
}: {
  options = {
    nx.desktop.hyprland = {
      lockTimeout.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "whether to lock the screen due to idle";
      };
      lockTimeout.duration = lib.mkOption {
        type = lib.types.int;
        # default 30 minutes
        default = 1800;
        description = "time before locking the screen";
      };
      screenTimeout.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "whether to turn off the screen due to idle";
      };
      screenTimeout.duration = lib.mkOption {
        type = lib.types.int;
        # default 1 hour
        default = 3600;
        description = "time before turning off the screen";
      };
      suspendTimeout.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "whether to suspend the system due to idle";
      };
      suspendTimeout.duration = lib.mkOption {
        type = lib.types.int;
        # default 2 hours
        default = 7200;
        description = "time before suspending the system";
      };
    };
  };
  config = lib.mkIf config.nx.desktop.hyprland.enable {
    home-manager.users.ben = {
      services.hypridle = let
        lockTimeout = config.nx.desktop.hyprland.lockTimeout.enable;
        screenTimeout = config.nx.desktop.hyprland.screenTimeout.enable;
        suspendTimeout = config.nx.desktop.hyprland.suspendTimeout.enable;
        lockTimeoutDuration = config.nx.desktop.hyprland.lockTimeout.duration;
        screenTimeoutDuration = config.nx.desktop.hyprland.screenTimeout.duration;
        suspendTimeoutDuration = config.nx.desktop.hyprland.suspendTimeout.duration;
      in {
        enable = true;
        settings = {
          general = {
            lock_cmd = "hyprctl dispatch exec hyprlock";
          };
          listener = [
            (lib.mkIf lockTimeout {
              timeout = lockTimeoutDuration;
              on-timeout = "hyprctl dispatch exec hyprlock";
            })
            (lib.mkIf screenTimeout {
              timeout = screenTimeoutDuration;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            })
            (lib.mkIf suspendTimeout {
              timeout = suspendTimeoutDuration;
              on-timeout = "systemctl suspend";
              on-resume = "hyprctl dispatch exec hyprlock";
            })
          ];
        };
      };
    };
  };
}
