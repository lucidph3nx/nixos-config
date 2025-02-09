{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.nx.desktop.hyprland.enable {
    home-manager.users.ben = {
      home.sessionPath = ["$HOME/.local/scripts"];
      home.file.".local/scripts/cli.system.setHyprGaps" = {
        executable = true;
        text =
          /*
          bash
          */
          ''
            #!/bin/sh
            width=$(hyprctl monitors -j | jq '.[0].width')

            # Check if running in super-ultrawide
            if [ $width -gt 5000 ]; then
              hyprctl keyword workspace "w[t1], gapsout:5 $((width / 4))"
              hyprctl keyword workspace "s[true], gapsout:50 $((width / 4))"
            else
              # unsetting is not possible, for now set to default
              # https://github.com/hyprwm/Hyprland/issues/5691
              hyprctl keyword workspace "w[t1], gapsout:5 5"
              hyprctl keyword workspace "s[true], gapsout:50 50"
            fi
          '';
      };
      home.file.".local/scripts/system.inputs.toggleTouchpad" = lib.mkIf config.nx.isLaptop {
        executable = true;
        text =
          /*
          bash
          */
          ''
            #!/bin/sh
            export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad_status"
            if ! [ -f "$STATUS_FILE" ]; then
              # disable touchpad
              hyprctl keyword 'device[asup1415:00-093a:300c-touchpad]:enabled' false > /dev/null
              touch "$STATUS_FILE"
              echo "disabled" > "$STATUS_FILE"
            elif [ "$(cat $STATUS_FILE)" = "enabled" ]; then
              # disable touchpad
              hyprctl keyword 'device[asup1415:00-093a:300c-touchpad]:enabled' false > /dev/null
              echo "disabled" > "$STATUS_FILE"
            elif [ "$(cat $STATUS_FILE)" = "disabled" ]; then
              # enable touchpad
              hyprctl keyword 'device[asup1415:00-093a:300c-touchpad]:enabled' true > /dev/null
              echo "enabled" > "$STATUS_FILE"
            fi
          '';
      };
      home.file.".local/scripts/cli.hyprland.switchWorkspaceOnWindowClose" = {
        executable = true;
        text =
          /*
          bash
          */
          ''
            #!/bin/sh
            function handle {
              if [[ "$1" == closewindow* ]]; then
                echo "Close Window detected"

                active_workspace=$(hyprctl activeworkspace -j | jq '.id')
                if [[ "$active_workspace" -ne 1 ]]; then
                  windows_count=$(hyprctl activeworkspace -j | jq '.windows')
                  if [[ "$windows_count" -eq 0 ]]; then
                    echo $windows_count
                    echo "Empty workspace detected"
                    hyprctl dispatch workspace m-1
                  fi
                fi
              fi
            }
            ${pkgs.socat}/bin/socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do handle "$line"; done
          '';
      };
      home.file.".local/scripts/cli.system.suspend" = {
        executable = true;
        text =
          /*
          bash
          */
          ''
            #!/bin/sh
            hyprctl dispatch exec hyprlock ;
            pkill -SIGUSR2 waybar
            systemctl suspend
          '';
      };
      home.file.".local/scripts/cli.system.inhibitIdle" = {
        executable = true;
        text =
          /*
          bash
          */
          ''
            #!/bin/sh
            LOCKFILE="/tmp/systemd_inhibit.lock"

            start_inhibit() {
                systemd-inhibit --what=idle --why="Preventing idle for a task" sleep infinity &
                echo $! > "$LOCKFILE"
            }

            stop_inhibit() {
                if [[ -f "$LOCKFILE" ]]; then
                    kill "$(cat "$LOCKFILE")"
                    rm -f "$LOCKFILE"
                fi
            }

            status_inhibit() {
                if [[ -f "$LOCKFILE" ]]; then
                    echo "Inhibit Active"
                else
                    echo "Inhibit Inactive"
                fi
            }

            case $1 in
                start)
                    if [[ -f "$LOCKFILE" ]]; then
                        echo "Inhibit already running."
                    else
                        start_inhibit
                        echo "Inhibit started."
                    fi
                    ;;
                stop)
                    stop_inhibit
                    echo "Inhibit stopped."
                    ;;
                status)
                    status_inhibit
                    ;;
                statusjson)
                    if [[ -f "$LOCKFILE" ]]; then
                        echo '{"text": "IDLE INHIBIT", "class": "active"}'
                    else
                        echo '{"text": "", "class": "inactive"}'
                    fi
                    ;;
                toggle)
                    if [[ -f "$LOCKFILE" ]]; then
                        stop_inhibit
                        echo "Inhibit toggled off."
                    else
                        start_inhibit
                        echo "Inhibit toggled on."
                    fi
                    ;;
                *)
                    echo "Usage: $0 {start|stop|status|toggle}"
                    exit 1
                    ;;
            esac
          '';
      };
    };
  };
}
