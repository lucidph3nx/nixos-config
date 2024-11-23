{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}: let
  browserNewWindow = "firefox --new-window";
  externalAudio = osConfig.nixModules.externalAudio.enable;
  enableHomeAutomation = config.homeManagerModules.homeAutomation.enable;
  location = osConfig.nixModules.deviceLocation;
  enableMpd = config.homeManagerModules.mpd.enable;
  enableHyprland = config.homeManagerModules.hyprland.enable;
  enableSway = config.homeManagerModules.sway.enable;
  mouseBattery = config.homeManagerModules.waybar.mouseBattery;
  homeDir = config.home.homeDirectory;
  fontsize = config.homeManagerModules.waybar.fontSize;
  isLaptop = osConfig.nixModules.isLaptop;
in
  with config.theme; {
    options = {
      homeManagerModules.waybar = {
        enable = lib.mkEnableOption "enables waybar";
        mouseBattery = lib.mkEnableOption "show mouse battery via opernrazer";
        fontSize = lib.mkOption {
          type = lib.types.str;
          default = "18px";
          description = "set the font size for waybar";
        };
      };
    };
    config = lib.mkIf config.homeManagerModules.waybar.enable {
      programs.waybar = {
        enable = true;
        package = pkgs.waybar;
        systemd.target = "sway-session.target";
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            height = 25;
            modules-left = [
              (lib.mkIf enableSway "sway/workspaces")
              (lib.mkIf enableSway "sway/scratchpad")
              (lib.mkIf enableSway "sway/mode")
              (lib.mkIf enableHyprland "hyprland/workspaces")
              (lib.mkIf enableHyprland "hyprland/submap")
              (lib.mkIf enableMpd "custom/mpd")
            ];
            modules-center = [
              "hyprland/window"
            ];
            modules-right = [
              "tray"
              (lib.mkIf mouseBattery "custom/mouse-battery")
              (lib.mkIf (externalAudio == false) "pulseaudio")
              (lib.mkIf externalAudio "custom/audio-enabled")
              (lib.mkIf (enableHomeAutomation && location == "office") "custom/office-temp")
              (lib.mkIf (enableHomeAutomation && location == "office") "custom/office-humidity")
              "custom/notification"
              "network"
              (lib.mkIf isLaptop "battery")
              "custom/inhibitidle"
              "custom/clock"
            ];
            "sway/workspaces" = {
              "all-outputs" = false;
              "disable-scroll" = true;
            };
            "sway/scratchpad" = {
              "format" = "{icon} {count}";
              "show-empty" = false;
              "format-icons" = ["" "󰎝"];
              "tooltip" = true;
              "tooltip-format" = "{app}: {title}";
            };
            "hyprland/window" = {
              "format" = "{title}";
              "rewrite" = {
                "(.*) — Mozilla Firefox" = "$1";
              };
            };
            # "mpd" = lib.mkIf enableMpd {
            #   "unknown-tag" = "";
            #   "format" = "{stateIcon} {artist} - {title} ({elapsedTime:%M:%S}) ";
            #   "format-disconnected" = "";
            #   "format-stopped" = "";
            #   "interval" = 10;
            #   "state-icons" = {
            #     "paused" = "";
            #     "playing" = "";
            #   };
            #   "tooltip-format" = "MPD (connected)";
            #   "tooltip-format-disconnected" = "MPD (disconnected)";
            #   "on-click" = "kitty ncmpcpp";
            # };
            "custom/mpd" = lib.mkIf enableMpd {
              "return-type" = "string";
              "interval" = 1;
              "exec" = "${homeDir}/.local/scripts/cli.mpd.nowPlaying";
            };
            "custom/office-temp" = lib.mkIf enableHomeAutomation {
              "return-type" = "string";
              "interval" = 60;
              "format" = " {}";
              "exec" = "${homeDir}/.local/scripts/cli.home.office.getTemperature";
              "on-click" = "${browserNewWindow} https://home-assistant.$SECRET_DOMAIN/lovelace/default_view";
            };
            "custom/office-humidity" = lib.mkIf enableHomeAutomation {
              "return-type" = "string";
              "interval" = 60;
              "format" = " {}";
              "exec" = "${homeDir}/.local/scripts/cli.home.office.getHumidity";
              "on-click" = "${browserNewWindow} https://home-assistant.$SECRET_DOMAIN/lovelace/default_view";
            };
            "tray" = {
              "icon-size" = 18;
              "spacing" = 12;
            };
            "pulseaudio" = lib.mkIf (externalAudio == false) {
              "format" = "󰕾 {volume}%";
              "format-muted" = "󰖁 {volume}%";
              "on-click" = "qpwgraph";
            };
            # "custom/audio-cycle" = lib.mkIf enableAudio {
            #   "return-type" = "json";
            #   "exec-on-event" = true;
            #   "interval" = 1;
            #   "format" = "{alt}";
            #   "exec" = "${homeDir}/.local/scripts/cli.audio.getOutput";
            #   "exec-if" = "sleep 0.5"; # Give enough time for script to get output
            #   "on-click" = "${homeDir}/.local/scripts/system.audio.switchOutput";
            # };
            "custom/audio-enabled" = {
              "return-type" = "string";
              "interval" = 1;
              "exec" = "${homeDir}/.local/scripts/cli.audio.outputEnabled";
            };
            "custom/inhibitidle" = {
              "return-type" = "json";
              "interval" = 1;
              "exec" = "${homeDir}/.local/scripts/cli.system.inhibitIdle statusjson";
              "format" = "{}";
            };
            "custom/clock" = {
              "return-type" = "string";
              "interval" = 1;
              "exec" = "date +'%F %T'";
            };
            "custom/notification" = {
              "tooltip" = false;
              "format" = "{icon}";
              "format-icons" = {
                "notification" = "<span foreground='${red}'><sup></sup></span>";
                "none" = "";
                "dnd-notification" = "<span foreground='${red}'><sup></sup></span>";
                "dnd-none" = "";
              };
              "return-type" = "json";
              "exec-if" = "which swaync-client";
              "exec" = "swaync-client -swb";
              "on-click" = "swaync-client -t -sw";
              "on-click-right" = "swaync-client -d -sw";
              "escape" = true;
            };
            "custom/mouse-battery" = lib.mkIf mouseBattery {
              "return-type" = "json";
              "interval" = 60;
              "exec" = "${homeDir}/.local/scripts/home.mouse.batteryIndicator";
              # "exec" = "polychromatic-cli -d mouse -k | grep Battery | sed 's/[^0-9]*//g'";
              "format" = "{}";
            };
            "network" = {
              # don't show when on ethernet
              "format-ethernet" = "";
              "format-wifi" = "󱚽";
              "tooltip-format-wifi" = "{essid} ({signalStrength}%)";
            };
            "battery" = {
              "format-icons" = ["󱊡" "󱊢" "󱊣"];
              "format-charging" = "{capacity}% 󰂄";
              "format" = "{capacity}% {icon}";
              "interval" = "5";
            };
          };
        };
        style = ''
          * {
            border: none;
            border-radius: 0;
            font-family: JetBrainsMono Nerd Font, monospace;
            font-size: ${fontsize};
            font-weight: 500;
            min-height: 0;
          }
          window#waybar {
            background-color: ${bg0};
            color: ${foreground};
          }
          window#waybar.hidden {
            opacity: 0.2;
          }
          #workspaces {
            padding: 0px 0px 0px 0px;
          }
          /* for hyprland its active instead of focused*/
          #workspaces button.active {
            color: ${bg0};
            background-color: ${primary};
          }
          #workspaces button.focused {
            background-color: ${secondary};
            color: ${bg0};
          }
          #workspaces button.urgent {
            background-color: ${red};
            color: ${bg0};
          }
          #workspaces button:hover {
            transition-duration: 0s;
            box-shadow: inherit;
            text-shadow: inherit;
            background: ${secondary};
            color: ${bg0};
          }
          #workspaces button {
            color: ${foreground};
            min-width: 25px;
          }
          #scratchpad {
            background-color: ${blue};
            color: ${bg0};
            padding: 2px 5px;
          }
          #mode {
            padding-left: 10px;
            padding-right: 10px;
            background-color: ${green};
            color: ${bg0};
          }
          #submap {
            padding-left: 10px;
            padding-right: 10px;
            background-color: ${red};
            color: ${bg0};
          }
          #custom-mpd {
            padding-right: 10px;
            padding-left: 10px;
          }
          /* hide when stopped  or disconnected*/
          #mpd.stopped, #mpd.disconnected {
              font-size: 0;
              margin: 0;
              padding: 0;
          }
          widget > * {
              padding-top: 2px;
              padding-bottom: 2px;
          }
          .modules-left > widget:first-child > * {
            margin-left: 0px;
          }
          .modules-left > widget:last-child > * {
            margin-right: 18px;
          }
          .modules-right > widget > * {
            padding: 0 12px;
            margin-left: 0;
            margin-right: 0;
            color: ${bg0};
            background-color: ${primary};
          }
          @keyframes blink {
            to {
              color: ${green};
            }
          }
          #tray {
            background: ${bg0};
          }
          #custom-inhibitidle.active {
            color: ${bg0};
            background-color: ${red};
          }
          #custom-mouse-battery.low {
            color: ${bg0};
            background-color: ${red};
          }
          #custom-mouse-battery.full {
            color: ${bg0};
            background-color: ${blue};
          }
          label:focus {
            background-color: ${bg0};
          }
          tooltip {
            background: ${bg0};
          }
          tooltip label {
            color: ${green};
            text-shadow: none;
          }
        '';
      };
      home.file.".local/scripts/cli.mpd.nowPlaying" = {
        executable = true;
        text =
          /*
          bash
          */
          ''
            #!/bin/sh

            # Fetch the mpc output and split it into three parts
            json=$(mpc -f '{"name":"%name%", "artist":"%artist%", "album":"%album%", "title":"%title%", "time":"%time%"}' | head -n 1)
            status=$(mpc status | sed -n '2p')  # Second line contains the playback status and timing info
            player=$(mpc status | sed -n '3p') # Third line contains volume, repeat, random, etc.

            # Parse the metadata with jq
            artist=$(echo "$json" | jq -r '.artist' 2>/dev/null)
            name=$(echo "$json" | jq -r '.name' 2>/dev/null)
            title=$(echo "$json" | jq -r '.title' 2>/dev/null)

            # Use name if artist is not available
            if [ -n "$artist" ]; then
                display_artist="$artist"
            else
                display_artist="$name"
            fi

            # Parse the playback status
            playing=$(echo "$status" | grep -oP '^\[.*\]')
            elapsed_time=$(echo "$status" | grep -oP '\d+:\d+' | head -n 1)
            total_time=$(echo "$status" | grep -oP '\d+:\d+' | tail -n 1)

            # Determine the now playing icon
            if echo "$playing" | grep -q "\[playing\]"; then
                play_icon=""
            elif echo "$playing" | grep -q "\[paused\]"; then
                play_icon=""
            else
                play_icon="" # Default icon for stopped
            fi

            if [ "$total_time" != "0:00" ] && [ -n "$total_time" ]; then
                time_info=" ($elapsed_time/$total_time)"
            else
                time_info=""
            fi

            # Format the output
            if [ -n "$display_artist" ] && [ -n "$title" ]; then
                now_playing="$play_icon $display_artist - $title$time_info 󰝚"
            else
                now_playing=""
            fi

            # replace ampersands with html entities
            now_playing=$(echo "$now_playing" | sed 's/&/\&amp;/g')
            # Output the friendly now playing message
            echo "$now_playing"
          '';
      };
    };
  }
