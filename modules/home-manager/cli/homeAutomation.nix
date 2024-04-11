{ config, pkgs, inputs, lib, ... }: 

{
  options = {
    home-manager-modules.homeAutomation.enable =
      lib.mkEnableOption "enables home automation scripts etc";
  };
  config = lib.mkIf config.home-manager-modules.homeAutomation.enable {
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
  };
}
