{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.pipewire-utils = {
      enable = lib.mkEnableOption "enables pipwire-utils";
    };
  };
  config = lib.mkIf config.homeManagerModules.pipewire-utils.enable {
    # my scripts relevant to pipewire
    home.sessionPath = ["$HOME/.local/scripts"];
    # home.file.".local/scripts/system.audio.switchOutput" = {
    #   executable = true;
    #   text =
    #     /*
    #     bash
    #     */
    #     ''
    #       #!/bin/sh
    #       # Find the ID of the current default sink
    #       current_sink_id=$(wpctl inspect @DEFAULT_SINK@ | awk 'NR==1 {gsub(/,/, "", $2); print $2}')
    #
    #       # Get the IDs of all sinks with priority.session >= 1000
    #       all_sink_ids=$(pw-dump | jq -r '.[] | select(.type == "PipeWire:Interface:Node" and .info.props."media.class" == "Audio/Sink" and .info.props."priority.session" >= 1000) | .id')
    #
    #       # Filter out the current sink ID
    #       next_sink_id=$(echo "$all_sink_ids" | grep -v "$current_sink_id" | head -n 1)
    #
    #       # Set the next sink as the default sink
    #       wpctl set-default $next_sink_id
    #     '';
    # };
  };
}
