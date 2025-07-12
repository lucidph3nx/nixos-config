{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.nx.services.batteryNotifier;

  battery-notifier-script =
    pkgs.writers.writePython3Bin "battery-notifier" {
      # Ignore linter errors for line length (E501) and line breaks (W503),
      # as Nix path expansion makes these checks impractical.
      flakeIgnore = ["E501" "W503"];
    } ''
      import argparse
      import json
      import os
      import subprocess
      from pathlib import Path


      def get_command_output(cmd):
          """Executes a shell command and returns its output."""
          if not cmd:
              return None
          try:
              result = subprocess.run(
                  cmd, shell=True, check=True, capture_output=True, text=True
              )
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
              return {"last_notification": "none", "last_id": "0", "full_notification_done": False}
          try:
              with open(state_file, "r") as f:
                  state = json.load(f)
                  # Add new keys with default values if they don't exist
                  if "full_notification_done" not in state:
                      state["full_notification_done"] = False
                  return state
          except json.JSONDecodeError:
              return {"last_notification": "none", "last_id": "0", "full_notification_done": False}


      def close_notification(notif_id):
          """Closes a notification by its ID using dunstify."""
          if notif_id != "0":
              dunstify_path = "${pkgs.dunst}/bin/dunstify"
              subprocess.run([dunstify_path, "-C", str(notif_id)])


      def send_notification(last_id, icon, title, body):
          """Sends or replaces a dunstify notification and returns the new ID."""
          dunstify_path = "${pkgs.dunst}/bin/dunstify"
          cmd = [
              dunstify_path,
              "-p",  # Print the new notification ID to stdout
              "-i",
              icon,
              "-u",
              "critical",  # Keep notifications persistent
              "-r",
              str(last_id),
              title,
              body,
          ]
          result = subprocess.run(cmd, capture_output=True, text=True)
          return result.stdout.strip()


      def main():
          parser = argparse.ArgumentParser(
              description="Monitor battery and send notifications."
          )
          parser.add_argument(
              "--name", required=True, help="Device name (e.g., 'Laptop', 'Mouse')"
          )
          parser.add_argument(
              "--level-cmd", required=True, help="Command to get battery level"
          )
          parser.add_argument(
              "--status-cmd", help="Command to get battery status (e.g., 'Charging')"
          )
          parser.add_argument("--low-threshold", type=int, default=20)
          parser.add_argument("--full-threshold", type=int, default=100)
          parser.add_argument("--dismiss-threshold", type=int, default=50)
          parser.add_argument("--re-notify-threshold", type=int, default=60)
          parser.add_argument(
              "--ignore-zero", action="store_true", help="Ignore 0% battery readings"
          )
          args = parser.parse_args()

          # --- Get Current Status ---
          level_str = get_command_output(args.level_cmd)
          if level_str is None or not level_str.isdigit():
              print(f"Error: Could not get a valid battery level for {args.name}.")
              return

          level = int(level_str)

          if args.status_cmd:
              status = get_command_output(args.status_cmd)
          else:
              status = "Unknown"

          is_charging = status == "Charging" or status == "Full"
          is_discharging = status == "Discharging"

          if args.ignore_zero and level == 0:
              print(f"Ignoring 0% reading for {args.name} as requested.")
              return

          # --- Load State ---
          state_file = (
              Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp"))
              / f"battery_notifier_{args.name}.json"
          )
          state = load_state(state_file)
          last_notification_type = state["last_notification"]
          last_id = state["last_id"]
          full_notification_done = state["full_notification_done"]

          # --- State Machine ---

          # 1. Handle dismissal conditions first.
          # If a notification is dismissed, update the local state and continue,
          # allowing a new notification to be created in the same run if needed.
          if last_notification_type == "full" and is_discharging:
              close_notification(last_id)
              state = {"last_notification": "none", "last_id": "0", "full_notification_done": True}
              save_state(state_file, state)
              last_notification_type, last_id, full_notification_done = state["last_notification"], state["last_id"], state["full_notification_done"]

          if last_notification_type == "low" and level >= args.dismiss_threshold:
              close_notification(last_id)
              state = {"last_notification": "none", "last_id": "0", "full_notification_done": full_notification_done}
              save_state(state_file, state)
              last_notification_type, last_id = state["last_notification"], state["last_id"]

          # Reset full_notification_done flag if battery drops below re-notify threshold while discharging
          if status == "Discharging" and level <= args.re_notify_threshold:
              state["full_notification_done"] = False
              save_state(state_file, state)
              full_notification_done = state["full_notification_done"]

          # 2. Handle notification creation/update conditions.

          # LOW state
          if level <= args.low_threshold:
              if level < args.dismiss_threshold:
                  title = f"{args.name} Battery Low"
                  body = f"Level: {level}%."

                  icon = "battery-caution"
                  if level <= (args.low_threshold / 2):
                      icon = "battery-empty"

                  if is_charging:
                      body += " Plugged in."
                      icon = "battery-low-charging"
                  else:
                      body += " Please plug in."

                  new_id = send_notification(last_id, icon, title, body)
                  state_to_save = {"last_notification": "low", "last_id": new_id, "full_notification_done": full_notification_done}
                  save_state(state_file, state_to_save)
              # If we are in the low state, and a notification was sent, we are done.
              # Otherwise, if we are in the low state but above dismiss threshold,
              # we might have just dismissed a notification, so we continue to check
              # if a new notification is needed (which it won't be in this case).
              return

          # FULL state
          if level >= args.full_threshold and is_charging:
              if last_notification_type != "full" and not full_notification_done:
                  title = f"{args.name} Fully Charged"
                  body = f"Level: {level}%. You can unplug."
                  new_id = send_notification(
                      "0", "battery-full-charged", title, body
                  )
                  state_to_save = {"last_notification": "full", "last_id": new_id, "full_notification_done": True}
                  save_state(state_file, state_to_save)

          # NORMAL state (neither low nor full, and not charging to full)
          # If there was a previous notification (low or full), dismiss it.
          if last_notification_type != "none" and not (level >= args.full_threshold and is_charging):
              close_notification(last_id)
              state = {"last_notification": "none", "last_id": "0", "full_notification_done": full_notification_done}
              save_state(state_file, state)
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
          udevTrigger = lib.mkEnableOption "udev trigger for this device";

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

          reNotifyThreshold = lib.mkOption {
            type = lib.types.int;
            default = 60;
            description = "The battery percentage at which to re-enable full battery notifications after it has been fully charged and discharged.";
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
    # UDEV rule to trigger the script on power supply changes.
    services.udev.extraRules = let
      # This wrapper script is run by udev (as root) and uses machinectl
      # to correctly start the user service in the user's session.
      udev-wrapper = pkgs.writeShellScriptBin "udev-battery-notifier" ''
        #!${pkgs.runtimeShell}
        # The device name (e.g., "laptop") is passed as the first argument
        DEVICE_NAME=$1
        # The user to run the service as.
        USER="ben"
        # Use machinectl to execute the command within the user's session scope.
        # This is the standard systemd way to bridge a system event to a user action.
        ${pkgs.systemd}/bin/machinectl shell \
          ''${USER}@.host \
          /bin/sh -c "systemctl --user --no-block start battery-notifier-event-''${DEVICE_NAME}.service"
      '';
    in ''
      # This rule triggers whenever the AC adapter is plugged in or out.
      ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="${udev-wrapper}/bin/udev-battery-notifier laptop"
    '';

    home-manager.users.ben = lib.mkIf (builtins.any (d: d.enable) (lib.attrValues cfg.devices)) {
      home.packages = with pkgs; [
        polychromatic
        dunst
        libnotify
      ];

      # Merged systemd services definition
      systemd.user.services =
        # Polling services (triggered by timers)
        (lib.attrsets.mapAttrs' (name: device:
          lib.nameValuePair "battery-notifier-${name}" {
            Unit = {
              Description = "Run polling battery notifier for ${name}";
            };
            Service = {
              Type = "oneshot";
              ExecStart = ''
                ${battery-notifier-script}/bin/battery-notifier \
                  --name "${name}" \
                  --level-cmd '${device.levelCmd}' \
                  ${lib.optionalString (device.statusCmd != null) "--status-cmd '${device.statusCmd}'"} \
                  --low-threshold ${toString device.lowThreshold} \
                  --full-threshold ${toString device.fullThreshold} \
                  --dismiss-threshold ${toString device.dismissThreshold} \
                  --re-notify-threshold ${toString device.reNotifyThreshold} \
                  ${lib.optionalString device.ignoreZero "--ignore-zero"}
              '';
            };
          }) (lib.filterAttrs (n: v: v.enable) cfg.devices))
        //
        # Event-driven services (triggered by udev)
        (lib.attrsets.mapAttrs' (name: device:
          lib.nameValuePair "battery-notifier-event-${name}" {
            Unit = {
              Description = "Run event-driven battery notifier for ${name}";
            };
            Service = {
              Type = "oneshot";
              ExecStart = ''
                ${battery-notifier-script}/bin/battery-notifier \
                  --name "${name}" \
                  --level-cmd '${device.levelCmd}' \
                  ${lib.optionalString (device.statusCmd != null) "--status-cmd '${device.statusCmd}'"} \
                  --low-threshold ${toString device.lowThreshold} \
                  --full-threshold ${toString device.fullThreshold} \
                  --dismiss-threshold ${toString device.dismissThreshold} \
                  --re-notify-threshold ${toString device.reNotifyThreshold} \
                  ${lib.optionalString device.ignoreZero "--ignore-zero"}
              '';
            };
          }) (lib.filterAttrs (n: v: v.enable && v.udevTrigger) cfg.devices));

      systemd.user.timers = lib.attrsets.mapAttrs' (name: device:
        lib.nameValuePair "battery-notifier-${name}" {
          Unit = {
            Description = "Run battery notifier timer for ${name}";
          };
          Timer = device.timerConfig // {Unit = "battery-notifier-${name}.service";};
          Install = {
            WantedBy = ["timers.target"];
          };
        }) (lib.filterAttrs (n: v: v.enable) cfg.devices);
    };

    nx.services.batteryNotifier.devices = {
      laptop = {
        enable = config.nx.isLaptop;
        udevTrigger = true; # Enable the udev trigger for the laptop
        levelCmd = "cat /sys/class/power_supply/BAT0/capacity";
        statusCmd = "cat /sys/class/power_supply/BAT0/status";
        lowThreshold = 20;
        dismissThreshold = 50;
        reNotifyThreshold = 60;
      };
      mouse = {
        enable = true;
        udevTrigger = false; # The mouse doesn't have a standard udev event
        levelCmd = "${pkgs.polychromatic}/bin/polychromatic-cli -d mouse -k | grep Battery | sed 's/[^0-9]*//g' || echo 100";
        statusCmd = "if ${pkgs.polychromatic}/bin/polychromatic-cli -d mouse -k | grep -q '(charging)'; then echo 'Charging'; else echo 'Discharging'; fi";
        lowThreshold = 20;
        dismissThreshold = 50;
        ignoreZero = true;
        reNotifyThreshold = 60;
      };
    };
  };
}
