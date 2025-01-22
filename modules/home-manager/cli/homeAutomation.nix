{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.homeAutomation.enable =
      lib.mkEnableOption "enables home automation scripts etc";
  };
  config = lib.mkIf config.homeManagerModules.homeAutomation.enable {
    # my scripts relevant to homeAutomation
    home.sessionPath = ["$HOME/.local/scripts"];

    # This script returns the current humidity in my office via home assistant
    home.file.".local/scripts/cli.home.office.getHumidity" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.curl}/bin/curl -X GET \
          -H "Authorization: Bearer ''${HASS_API_KEY}" \
          -H "Content-Type: application/json" \
          -s \
          https://home-assistant.''${SECRET_DOMAIN}/api/states/sensor.office_sensor_humidity \
          | ${pkgs.jq}/bin/jq -r '. | "\(.state)\(.attributes.unit_of_measurement)"'
      '';
    };
    # This script returns the current temperature in my office via home assistant
    home.file.".local/scripts/cli.home.office.getTemperature" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.curl}/bin/curl -X GET \
          -H "Authorization: Bearer ''${HASS_API_KEY}" \
          -H "Content-Type: application/json" \
          -s \
          https://home-assistant.''${SECRET_DOMAIN}/api/states/sensor.office_sensor_temperature \
          | ${pkgs.jq}/bin/jq -r '. | "\(.state)\(.attributes.unit_of_measurement)"'
      '';
    };
    # This script opens the blinds in the office
    home.file.".local/scripts/home.office.openBlinds" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.curl}/bin/curl -X POST \
          -H "Authorization: Bearer ''${HASS_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity_id": "cover.office_blinds"}' \
          https://home-assistant.''${SECRET_DOMAIN}/api/services/cover/open_cover
      '';
    };
    # This script closes the blinds in the office
    home.file.".local/scripts/home.office.closeBlinds" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.curl}/bin/curl -X POST \
          -H "Authorization: Bearer ''${HASS_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity_id": "cover.office_blinds"}' \
          https://home-assistant.''${SECRET_DOMAIN}/api/services/cover/close_cover
      '';
    };
    # This script closes only the LEFT blind in the office
    home.file.".local/scripts/home.office.closeBlindsLeft" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.curl}/bin/curl -X POST \
          -H "Authorization: Bearer ''${HASS_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity_id": "cover.office_left"}' \
          https://home-assistant.''${SECRET_DOMAIN}/api/services/cover/close_cover
      '';
    };
    # This script closes only the RIGHT blind in the office
    home.file.".local/scripts/home.office.closeBlindsRight" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.curl}/bin/curl -X POST \
          -H "Authorization: Bearer ''${HASS_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity_id": "cover.office_right"}' \
          https://home-assistant.''${SECRET_DOMAIN}/api/services/cover/close_cover
      '';
    };
    # Turns on the heater in the office
    home.file.".local/scripts/home.office.heaterOn" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.curl}/bin/curl -X POST \
          -H "Authorization: Bearer ''${HASS_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity_id": "switch.office_heater"}' \
          https://home-assistant.''${SECRET_DOMAIN}/api/services/switch/turn_on
      '';
    };
    # Turns off the heater in the office
    home.file.".local/scripts/home.office.heaterOff" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.curl}/bin/curl -X POST \
          -H "Authorization: Bearer ''${HASS_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity_id": "switch.office_heater"}' \
          https://home-assistant.''${SECRET_DOMAIN}/api/services/switch/turn_off
      '';
    };
    # relevant home automation keyboard shortcuts in sway
    wayland.windowManager.sway.config = lib.mkIf config.homeManagerModules.homeAutomation.enable {
      keybindings = let
        super = "Mod4";
        pageup = "Prior";
        pagedown = "Next";
        homeDir = config.home.homeDirectory;
      in {
        "${super}+${pageup}" = "exec ${homeDir}/.local/scripts/home.office.openBlinds";
        "${super}+${pagedown}" = "exec ${homeDir}/.local/scripts/home.office.closeBlinds";
      };
    };
    wayland.windowManager.hyprland.settings = lib.mkIf config.homeManagerModules.homeAutomation.enable {
      bind = let
        pageup = "Prior";
        pagedown = "Next";
        homeDir = config.home.homeDirectory;
      in [
        "SUPER, ${pageup}, exec, ${homeDir}/.local/scripts/home.office.openBlinds"
        "SUPER, ${pagedown}, exec, ${homeDir}/.local/scripts/home.office.closeBlinds"
      ];
    };
    # This script turns off the grow lights
    home.file.".local/scripts/home.office.turnGrowlightsOff" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.curl}/bin/curl -X POST \
          -H "Authorization: Bearer ''${HASS_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity_id": "automation.growlight_off"}' \
          https://home-assistant.''${SECRET_DOMAIN}/api/services/automation/trigger
      '';
    };
    # This script turns on the grow lights
    home.file.".local/scripts/home.office.turnGrowlightsOn" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.curl}/bin/curl -X POST \
          -H "Authorization: Bearer ''${HASS_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity_id": "automation.growlight_timer"}' \
          https://home-assistant.''${SECRET_DOMAIN}/api/services/automation/trigger
      '';
    };
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

          # Read last state
          if [[ -f $STATE_FILE ]]; then
              source "$STATE_FILE"
          else
              echo "last_notification=none" > "$STATE_FILE"
              last_notification="none"
          fi

          # Get battery level
          battery_level=$(${pkgs.polychromatic}/bin/polychromatic-cli -d mouse -k | grep Battery | sed 's/[^0-9]*//g')

          # Ignore erroneous 0% battery level
          if [[ "$battery_level" -eq 0 ]]; then
              exit 0
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
}
