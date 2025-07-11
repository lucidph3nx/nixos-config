{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.services.laptopBatteryMonitor.enable =
      lib.mkEnableOption "A systemd service to monitor and notify laptop battery status"
      // {
        default = true;
      };
  };

  config = lib.mkIf (config.nx.services.laptopBatteryMonitor.enable && config.nx.isLaptop) {
    home-manager.users.ben = {
      # We add dunst here to get the `dunstify` command, which allows closing notifications by ID.
      home.packages = with pkgs; [
        polychromatic
        dunst
      ];

      # a systemd service to monitor the battery level of my laptop and send notifications
      systemd.user.services.laptop-battery-monitor = let
        # We use writeShellScriptBin to ensure dunstify is in the PATH for the script.
        laptop-battery-monitor =
          pkgs.writeShellScriptBin "laptop-battery-monitor"
          ''
            #!/usr/bin/env bash

            # --- Configuration ---
            LOW_BATTERY=20
            FULL_BATTERY=100
            DISMISS_THRESHOLD=50 # Dismiss the 'low battery' notification when the level is above this.
            
            # --- System Paths ---
            BATTERY_PATH="/sys/class/power_supply/BAT0"
            STATE_FILE="$XDG_RUNTIME_DIR/laptop_battery_state"

            # Exit if the battery path doesn't exist.
            if [[ ! -d "$BATTERY_PATH" ]]; then
              exit 0
            fi

            # --- Get Current Status ---
            current_level=$(cat "$BATTERY_PATH/capacity")
            current_status=$(cat "$BATTERY_PATH/status") # e.g., Discharging, Charging, Full

            # --- Load Previous State ---
            # If the state file exists, source it. Otherwise, initialize with default values.
            if [[ -f "$STATE_FILE" ]]; then
              source "$STATE_FILE"
            else
              last_notification="none"
              last_id=""
            fi

            # --- Helper Functions ---
            save_state() {
              # Saves the notification type and ID to the state file.
              # $1: notification type (e.g., "low", "full", "none")
              # $2: notification id (can be empty)
              echo "last_notification=$1" > "$STATE_FILE"
              echo "last_id=$2" >> "$STATE_FILE"
            }

            close_notification() {
              # Closes the notification using its ID, if an ID is stored.
              if [[ -n "$last_id" ]]; then
                dunstify -C "$last_id" &>/dev/null
              fi
            }

            # --- Main State Machine ---

            # Transition: from 'full' to 'normal'
            # If the last notification was 'full' and the user has unplugged the cable.
            if [[ "$last_notification" == "full" && "$current_status" == "Discharging" ]]; then
              close_notification
              save_state "none" ""
              exit 0
            fi

            # State: LOW (handles creation, updates, and dismissal of the low battery notification)
            # This block is entered if we were already in a low state, or if the battery just dropped below the threshold.
            if [[ "$last_notification" == "low" || "$current_level" -le "$LOW_BATTERY" ]]; then
              
              # First, check if the condition is now resolved and the notification should be dismissed.
              if [[ "$current_level" -ge "$DISMISS_THRESHOLD" ]]; then
                close_notification
                save_state "none" ""
                exit 0
              fi

              # If not dismissing, then we create or update the notification.
              title="Laptop Battery Low"
              body="Level: $current_level%."
              icon="battery-low"

              if [[ "$current_status" != "Discharging" ]]; then
                body="$body Plugged in."
              else
                body="$body Please plug in."
              fi
              
              # Conditionally build the command to avoid an empty -r flag.
              # All notifications are now sent with 'critical' urgency to ensure they persist.
              if [[ -n "$last_id" ]]; then
                # Replace existing notification
                notif_id=$(dunstify -p -r "$last_id" -u critical -i "$icon" "$title" "$body")
              else
                # Create a new notification
                notif_id=$(dunstify -p -u critical -i "$icon" "$title" "$body")
              fi

              save_state "low" "$notif_id"
              exit 0
            fi

            # State: FULL (battery is full and not discharging)
            if [[ "$current_level" -ge "$FULL_BATTERY" && "$current_status" != "Discharging" ]]; then
              # Only notify once when we first enter the 'full' state.
              if [[ "$last_notification" != "full" ]]; then
                # Sent as critical to ensure it persists until unplugged.
                notif_id=$(dunstify -p -i "battery-full-charged" -u critical "Laptop Fully Charged" "Level: $current_level%. You can unplug.")
                save_state "full" "$notif_id"
              fi
              exit 0
            fi
            
            # State: NORMAL (between low and full thresholds)
            # If we reach this point, no action is needed. The logic above handles all transitions.
          '';
      in {
        Unit = {
          Description = "Laptop battery monitor";
          After = ["network-online.target"];
        };
        Service = {
          Type = "oneshot";
          # Use the path to the script generated by writeShellScriptBin
          ExecStart = "${laptop-battery-monitor}/bin/laptop-battery-monitor";
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };

      systemd.user.timers.laptop-battery-monitor = {
        Unit = {
          Description = "Run Laptop Battery Monitor Every 5 Minutes";
        };
        Timer = {
          OnBootSec = "1min";
          OnUnitActiveSec = "5min";
          Unit = "laptop-battery-monitor.service";
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };
    };
  };
}
