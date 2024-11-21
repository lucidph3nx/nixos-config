{
  config,
  pkgs,
  inputs,
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
          | ${pkgs.jq}/bin/jq -r '.attributes | "\(.humidity)\(.unit_of_measurement)"'
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
          | ${pkgs.jq}/bin/jq -r '.attributes | "\(.temperature)\(.unit_of_measurement)"'
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
        "SUPER, Prior, exec, ${homeDir}/.local/scripts/home.office.openBlinds"
        "SUPER, Next, exec, ${homeDir}/.local/scripts/home.office.closeBlinds"
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
    home.file.".local/scripts/home.mouse.batteryIndicator" = {
      executable = true;
      text =
        /*
        bash
        */
        ''
          #!/bin/sh
          battery_level=$(${pkgs.polychromatic}/bin/polychromatic-cli -d mouse -k | grep Battery | sed 's/[^0-9]*//g')
          low_battery=20
          # if equal to 0, disregard
          if [ "$battery_level" -eq 0 ]; then
            text=""
            tooltip=""
            class="error"
          # elif [ "$battery_level" -eq 100 ]; then
          #   text="󰍽 $battery_level% 󰂅"
          #   tooltip="Mouse battery full, please unplug"
          #   class="full"
          elif [ "$battery_level" -lt $low_battery ]; then
            text="󰍽 $battery_level%"
            tooltip="Mouse battery low, please plug in"
            class="low"
          else
            text=""
            tooltip=""
            class="hidden"
          fi
          # Format the output as JSON
          output=$(printf '{"text": "%s", "tooltip": "%s", "class": "%s"}' "$text" "$tooltip" "$class")
          echo "$output"
        '';
    };
  };
}
