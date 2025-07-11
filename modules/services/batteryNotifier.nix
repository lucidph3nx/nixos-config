{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.nx.services.batteryNotifier;

  battery-notifier-script =
    pkgs.writeScript "battery-notifier"
    /*
    python
    */
    ''
      #!${pkgs.python3.withPackages (ps: [ps.pydbus])}/bin/python
      import argparse
      import json
      import os
      import subprocess
      import sys
      from pathlib import Path

      # --- D-Bus Setup for Notifications ---
      try:
          bus = __import__("pydbus").SessionBus()
          notifications = bus.get("org.freedesktop.Notifications")
      except Exception as e:
          print(f"Error: Could not connect to D-Bus. Is a notification daemon running? {e}")
          sys.exit(1)

      def get_command_output(cmd):
          """Executes a shell command and returns its output."""
          if not cmd:
              return None
          try:
              result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
              return result.stdout.strip()
          except subprocess.CalledProcessError as e:
              print(f"Error running command '{cmd}': {e.stderr.strip()}")
              return None

      def save_state(state_file, state):
          """Saves the current state to a JSON file."""
          state_file.parent.mkdir(parents=True, exist_ok=True)
          with open(state_file, "w") as f:
              json.dump(state, f)

      def load_state(state_file):
          """Loads state from a JSON file, or returns a default."""
          if not state_file.exists():
              return {"last_notification": "none", "last_id": 0}
          try:
              with open(state_file, "r") as f:
                  return json.load(f)
          except json.JSONDecodeError:
              return {"last_notification": "none", "last_id": 0}

      def close_notification(notif_id):
          """Closes a notification by its ID."""
          if notif_id > 0:
              try:
                  notifications.CloseNotification(notif_id)
              except Exception:
                  # Ignore if the notification was already closed by the user
                  pass

      def main():
          parser = argparse.ArgumentParser(description="Monitor battery and send notifications.")
          parser.add_argument("--name", required=True, help="Device name (e.g., 'Laptop', 'Mouse')")
          parser.add_argument("--level-cmd", required=True, help="Command to get battery level")
          parser.add_argument("--status-cmd", help="Command to get battery status (e.g., 'Charging')")
          parser.add_argument("--low-threshold", type=int, default=20)
          parser.add_argument("--full-threshold", type=int, default=100)
          parser.add_argument("--dismiss-threshold", type=int, default=50)
          parser.add_argument("--ignore-zero", action="store_true", help="Ignore 0% battery readings")
          args = parser.parse_args()

          # --- Get Current Status ---
          level_str = get_command_output(args.level_cmd)
          if level_str is None or not level_str.isdigit():
              print(f"Error: Could not get a valid battery level for {args.name}.")
              return

          level = int(level_str)
          status = get_command_output(args.status_cmd) if args.status_cmd else "Unknown"

          if args.ignore_zero and level == 0:
              print(f"Ignoring 0% reading for {args.name} as requested.")
              return

          # --- Load State ---
          state_file = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / f"battery_notifier_{args.name}.json"
          state = load_state(state_file)
          last_notification_type = state["last_notification"]
          last_id = state["last_id"]

          # --- State Machine ---

          # 1. Handle dismissal conditions first
          if last_notification_type == "full" and status == "Discharging":
              close_notification(last_id)
              save_state(state_file, {"last_notification": "none", "last_id": 0})
              return

          if last_notification_type == "low" and level >= args.dismiss_threshold:
              close_notification(last_id)
              save_state(state_file, {"last_notification": "none", "last_id": 0})
              return

          # 2. Handle notification creation/update conditions
          app_name = "Battery Notifier"

          # LOW state
          if last_notification_type == "low" or level <= args.low_threshold:
              if level < args.dismiss_threshold: # Only show/update if below dismiss level
                  title = f"{args.name} Battery Low"
                  body = f"Level: {level}%."
                  if status and status != "Discharging":
                      body += " Plugged in."
                  else:
                      body += " Please plug in."

                  new_id = notifications.Notify(app_name, last_id, "battery-low", title, body, [], {}, -1)
                  save_state(state_file, {"last_notification": "low", "last_id": new_id})
              return

          # FULL state
          if level >= args.full_threshold and status != "Discharging":
              if last_notification_type != "full":
                  title = f"{args.name} Fully Charged"
                  body = f"Level: {level}%. You can unplug."
                  new_id = notifications.Notify(app_name, 0, "battery-full-charged", title, body, [], {}, -1)
                  save_state(state_file, {"last_notification": "full", "last_id": new_id})
              return

      if __name__ == "__main__":
          main()
    '';
in {
  options.nx.services.batteryNotifier = {
    devices = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          enable = lib.mkEnableOption "this battery notifier";

          lowThreshold = lib.mkOption {
            type = lib.types.int;
            default = 20;
            description = "The battery percentage to trigger a low battery notification.";
          };

          fullThreshold = lib.mkOption {
            type = lib.types.int;
            default = 100;
            description = "The battery percentage to trigger a full battery notification.";
          };

          dismissThreshold = lib.mkOption {
            type = lib.types.int;
            default = 50;
            description = "The battery percentage at which to dismiss the low battery notification.";
          };

          ignoreZero = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to ignore erroneous 0% battery readings.";
          };

          levelCmd = lib.mkOption {
            type = lib.types.str;
            description = "The shell command to get the battery level as an integer.";
          };

          statusCmd = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "The shell command to get the battery status (e.g., 'Discharging').";
          };

          timerConfig = lib.mkOption {
            type = lib.types.attrs;
            default = {
              OnBootSec = "1min";
              OnUnitActiveSec = "1min";
            };
            description = "Configuration for the systemd timer.";
          };
        };
      }));
      default = {};
      description = "Configuration for various devices to monitor.";
    };
  };

  config = {
    # The home-manager configuration is now conditional.
    # It will only be included in the build if at least one device is enabled.
    home-manager.users.ben = lib.mkIf (builtins.any (d: d.enable) (lib.attrValues cfg.devices)) {
      # add any packages needed for the battery notifier
      home.packages = with pkgs; [
        polychromatic # For mouse battery
        dunst         # For the notification daemon
      ];

      # Dynamically generate services and timers for each configured device
      systemd.user.services = lib.attrsets.mapAttrs' (name: device:
        lib.nameValuePair "battery-notifier-${name}" {
          serviceConfig = {
            Type = "oneshot";
            ExecStart = ''
              ${battery-notifier-script} \
                --name "${name}" \
                --level-cmd '${device.levelCmd}' \
                ${lib.optionalString (device.statusCmd != null) "--status-cmd '${device.statusCmd}'"} \
                --low-threshold ${toString device.lowThreshold} \
                --full-threshold ${toString device.fullThreshold} \
                --dismiss-threshold ${toString device.dismissThreshold} \
                ${lib.optionalString device.ignoreZero "--ignore-zero"}
            '';
          };
        }) (lib.filterAttrs (n: v: v.enable) cfg.devices);

      systemd.user.timers = lib.attrsets.mapAttrs' (name: device:
        lib.nameValuePair "battery-notifier-${name}" {
          Unit = {
            Description = "Run battery notifier for ${name}";
          };
          Timer = device.timerConfig // { Unit = "battery-notifier-${name}.service"; };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        }) (lib.filterAttrs (n: v: v.enable) cfg.devices);
    };

    # Devices are configured here
    nx.services.batteryNotifier.devices = {
      laptop = {
        enable = config.nx.isLaptop;
        levelCmd = "cat /sys/class/power_supply/BAT0/capacity";
        statusCmd = "cat /sys/class/power_supply/BAT0/status";
        lowThreshold = 20;
        dismissThreshold = 50;
      };
      mouse = {
        enable = true;
        levelCmd = "${pkgs.polychromatic}/bin/polychromatic-cli -d mouse -k | grep Battery | sed 's/[^0-9]*//g' || echo 100";
        statusCmd = "if ${pkgs.polychromatic}/bin/polychromatic-cli -d mouse -k | grep -q '(charging)'; then echo 'Charging'; else echo 'Discharging'; fi";
        lowThreshold = 20;
        dismissThreshold = 50;
        ignoreZero = true;
      };
    };
  };
}
