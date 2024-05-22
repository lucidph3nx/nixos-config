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
    home.file.".local/scripts/system.audio.switchOutput" = {
      executable = true;
      text =
        /*
        bash
        */
        ''
          #!/bin/sh
          # Find the ID of the current default sink
          current_sink_id=$(wpctl inspect @DEFAULT_SINK@ | awk 'NR==1 {gsub(/,/, "", $2); print $2}')

          # Get the IDs of all sinks with priority.session == 1009
          all_sink_ids=$(pw-dump | jq -r '.[] | select(.type == "PipeWire:Interface:Node" and .info.props."media.class" == "Audio/Sink" and .info.props."priority.session" == 1009) | .id')

          # Filter out the current sink ID
          next_sink_id=$(echo "$all_sink_ids" | grep -v "$current_sink_id" | head -n 1)

          # Set the next sink as the default sink
          wpctl set-default $next_sink_id
        '';
    };
    home.file.".local/scripts/cli.audio.getOutput" = {
      executable = true;
      text =
        /*
        bash
        */
        ''
          #!/bin/sh
          # a handy little lookup table to provide icons
          get_alt() {
              local text="$1"
              declare -A alt_lookup
              alt_lookup=(
                  ["Razer BlackShark V2 Pro"]="󰋋"
                  ["ALC1220 Analog"]="󰓃"
                  # Add more entries here as needed
              )
              echo ''${alt_lookup[$text]}
          }

          # Find the ID of the current default sink
          current_sink_id=$(wpctl inspect @DEFAULT_SINK@ | awk 'NR==1 {gsub(/,/, "", $2); print $2}')

          # Get the node.nick of the current default sink
          current_sink_nick=$(pw-dump | jq -r '.[] | select(.id == '$current_sink_id') | .info.props."node.nick"')
          alt=$(get_alt "$current_sink_nick")

          # Format the output as JSON
          output=$(printf '{"text": "%s", "alt": "%s", "tooltip": "%s"}' "$current_sink_nick" "$alt" "$current_sink_nick")
          echo "$output"
        '';
    };
  };
}
