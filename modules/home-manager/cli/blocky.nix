{
  osConfig,
  pkgs,
  lib,
  ...
}: {
  home.file.".local/scripts/system.blocky.pause" = lib.mkIf osConfig.nixModules.blocky.enable {
    executable = true;
    text =
      /*
      bash
      */
      ''
        #!/bin/sh
        response=$(${pkgs.blocky}/bin/blocky blocking disable --duration 10m --groups default 2>&1)
        cleaned_response=$(echo "$response" | awk '{print $NF}')

        if [ "$cleaned_response" = "OK" ]; then
          notify-send --expire-time 5000 "Blocky" "Blocky is disabled for 10 minutes"
        else
          notify-send "Blocky" "Error: $response"
        fi
      '';
  };
}
