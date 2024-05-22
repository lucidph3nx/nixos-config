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
    # This script turns off the hydroponics grow lights
    home.file.".local/scripts/home.hydroponics.turnOffGrowlights" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.curl}/bin/curl -X POST \
          -H "Authorization: Bearer ''${HASS_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity_id": "switch.hydro_growlights"}' \
          https://home-assistant.''${SECRET_DOMAIN}/api/services/switch/turn_off
      '';
    };
    # This script turns off the hydroponics grow lights
    home.file.".local/scripts/home.hydroponics.turnOnGrowlights" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.curl}/bin/curl -X POST \
          -H "Authorization: Bearer ''${HASS_API_KEY}" \
          -H "Content-Type: application/json" \
          -d '{"entity_id": "switch.hydro_growlights"}' \
          https://home-assistant.''${SECRET_DOMAIN}/api/services/switch/turn_on
      '';
    };
    # A script to pause the dns blocking via blocky for 10 min
    # TODO: figure out what I want to do with this
    # at the time of writing, blocky isnt working anyway
    home.file.".local/scripts/home.network.blockyPause" = {
      executable = true;
      source = ./files/home.network.blockyPause;
    };
  };
}
