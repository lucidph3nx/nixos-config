{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.services.mouseBatteryMonitor.enable =
      lib.mkEnableOption "A systemd service to monitor and notify mouse battery status"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.services.mouseBatteryMonitor.enable {
    hardware.openrazer = {
      enable = false; # temporary to prevent build failure of kernel module 2025-06-02
      # too many false positive 0% notifications
      batteryNotifier.enable = false;
    };
    home-manager.users.ben = {
      home.packages = with pkgs; [
        polychromatic
      ];
      # a systemd service to monitor the battery level of my mouse and send notifications
      systemd.user.services.mouse-battery-monitor = let
        mouse-battery-monitor =
          pkgs.writeShellScript "mouse-battery-monitor"
          /*
          bash
          */
          ''
            #!/bin/bash

            STATE_FILE="$XDG_RUNTIME_DIR/mouse_battery_state"
            LOW_BATTERY=20
            FULL_BATTERY=100

            # Get battery level
            battery_level=$(${pkgs.polychromatic}/bin/polychromatic-cli -d mouse -k | grep Battery | sed 's/[^0-9]*//g')

            # Ignore erroneous 0% battery level
            if [[ "$battery_level" -eq 0 ]]; then
                exit 0
            fi

            # Handle missing state file
            if [[ ! -f $STATE_FILE ]]; then
                if [[ "$battery_level" -eq $FULL_BATTERY ]]; then
                    # If the state file is missing but battery is 100%, avoid notifying
                    echo "last_notification=full" > "$STATE_FILE"
                    exit 0
                else
                    echo "last_notification=none" > "$STATE_FILE"
                    last_notification="none"
                fi
            else
                source "$STATE_FILE"
            fi

            # Notify on low battery
            if [[ "$battery_level" -lt $LOW_BATTERY && "$last_notification" != "low" ]]; then
                notify-send -i battery-low -u critical "Mouse Battery Low" "Battery level: $battery_level%. Please plug in."
                echo "last_notification=low" > "$STATE_FILE"
            elif [[ "$battery_level" -eq $FULL_BATTERY && "$last_notification" != "full" ]]; then
                # Notify when fully charged
                notify-send -i battery -u normal "Mouse Fully Charged" "Battery level: $battery_level%."
                echo "last_notification=full" > "$STATE_FILE"
            elif [[ "$battery_level" -ge $LOW_BATTERY && "$battery_level" -lt $FULL_BATTERY ]]; then
                # Reset state if conditions are normal
                echo "last_notification=none" > "$STATE_FILE"
            fi
          '';
      in {
        Unit = {
          Description = "Mouse battery monitor";
          After = ["network-online.target"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = mouse-battery-monitor;
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };
      systemd.user.timers.mouse-battery-monitor = {
        Unit = {
          Description = "Run Mouse Battery Monitor Every 5 Minutes";
        };
        Timer = {
          OnBootSec = "1min";
          OnUnitActiveSec = "5min";
          Unit = "mouse-battery-monitor.service";
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };
    };
  };
}
