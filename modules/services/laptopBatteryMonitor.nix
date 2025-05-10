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
      home.packages = with pkgs; [
        polychromatic
      ];
      # a systemd service to monitor the battery level of my laptop and send notifications
      systemd.user.services.laptop-battery-monitor = let
        laptop-battery-monitor =
          pkgs.writeShellScript "laptop-battery-monitor"
          /*
          bash
          */
          ''
            #!/bin/bash

            STATE_FILE="$XDG_RUNTIME_DIR/laptop_battery_state"
            LOW_BATTERY=20
            FULL_BATTERY=100

            # Get battery level
            battery_level=$(cat /sys/class/power_supply/BAT0/capacity)

            # Load existing state
            if [[ -f $STATE_FILE ]]; then
                source "$STATE_FILE"
            else
                if [[ "$battery_level" -eq $FULL_BATTERY ]]; then
                    # If the state file is missing but battery is 100%, avoid notifying
                    echo "last_notification=full" > "$STATE_FILE"
                    echo "last_id=" >> "$STATE_FILE"
                    exit 0
                else
                    echo "last_notification=none" > "$STATE_FILE"
                    echo "last_id=" >> "$STATE_FILE"
                fi
            fi

            # Notify on low battery
            if [[ "$battery_level" -lt $LOW_BATTERY ]]; then
                if [[ "$last_notification" == "low" && -n "$last_id" ]]; then
                    notif_id=$(notify-send -p -r "$last_id" -i battery-low -u critical "Laptop Battery Low" "Battery level: $battery_level%. Please plug in.")
                else
                    notif_id=$(notify-send -p -i battery-low -u critical "Laptop Battery Low" "Battery level: $battery_level%. Please plug in.")
                fi
                echo "last_notification=low" > "$STATE_FILE"
                echo "last_id=$notif_id" >> "$STATE_FILE"

            # Notify when fully charged
            elif [[ "$battery_level" -eq $FULL_BATTERY && "$last_notification" != "full" ]]; then
                notify-send -i battery -u normal "Laptop Fully Charged" "Battery level: $battery_level%."
                echo "last_notification=full" > "$STATE_FILE"
                echo "last_id=" >> "$STATE_FILE"

            # Reset state if conditions are normal (no notification)
            elif [[ "$battery_level" -ge $LOW_BATTERY && "$battery_level" -lt $FULL_BATTERY ]]; then
                echo "last_notification=none" > "$STATE_FILE"
                echo "last_id=" >> "$STATE_FILE"
            fi
          '';
      in {
        Unit = {
          Description = "laptop battery monitor";
          After = ["network-online.target"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = laptop-battery-monitor;
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };
      systemd.user.timers.laptop-battery-monitor = {
        Unit = {
          Description = "Run laptop Battery Monitor Every 5 Minutes";
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
