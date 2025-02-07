{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}: let
  externalAudio = osConfig.nx.externalAudio.enable;
  enableHomeAutomation = osConfig.nx.programs.homeAutomation.enable;
  location = osConfig.nx.deviceLocation;
  enableMpd = osConfig.nx.services.mpd.enable;
  enableHyprland = config.homeManagerModules.hyprland.enable;
  enableSway = config.homeManagerModules.sway.enable;
  homeDir = config.home.homeDirectory;
  fontsize = config.homeManagerModules.waybar.fontSize;
  isLaptop = osConfig.nx.isLaptop;
in
  with config.theme; {
    options = {
      homeManagerModules.waybar = {
        enable = lib.mkEnableOption "enables waybar";
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
          topBar = {
            name = "topBar";
            layer = "top";
            position = "top";
            height = 40;
            mode = "overlay";
            start_hidden = true;
            margin = "30"; # margin for the whole bar
            modules-left = [
              (lib.mkIf enableSway "sway/workspaces")
              (lib.mkIf enableSway "sway/scratchpad")
              (lib.mkIf enableSway "sway/mode")
              (lib.mkIf enableHyprland "hyprland/workspaces")
              (lib.mkIf enableHyprland "hyprland/submap")
            ];
            modules-center = [
              "hyprland/window"
            ];
            modules-right = [
              "tray"
              (lib.mkIf (externalAudio == false) "pulseaudio")
              (lib.mkIf externalAudio "custom/audio-enabled")
              (lib.mkIf (enableHomeAutomation && location == "office") "custom/office-temp")
              (lib.mkIf (enableHomeAutomation && location == "office") "custom/office-humidity")
              "custom/notification"
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
            "hyprland/workspaces" = {
              "persistent-workspaces" = {
                "*" = 9;
              };
            };
            "hyprland/window" = {
              "format" = "{title}";
              "rewrite" = {
                # remove the browser name from the title
                "(.*) — Mozilla Firefox" = "$1";
                "(.*) - qutebrowser" = "$1";
              };
            };
            "custom/office-temp" = lib.mkIf enableHomeAutomation {
              "return-type" = "string";
              "interval" = 60;
              "format" = " {}";
              "exec" = "${homeDir}/.local/scripts/cli.home.office.getTemperature";
            };
            "custom/office-humidity" = lib.mkIf enableHomeAutomation {
              "return-type" = "string";
              "interval" = 60;
              "format" = " {}";
              "exec" = "${homeDir}/.local/scripts/cli.home.office.getHumidity";
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
          };
          bottomBar = {
            name = "bottomBar";
            layer = "top";
            position = "bottom";
            height = 40;
            mode = "overlay";
            start_hidden = true;
            margin = "30"; # margin for the whole bar
            modules-left = [
              (lib.mkIf enableMpd "custom/mpd")
            ];
            modules-center = [];
            modules-right = [
              "cpu"
              "memory"
              "network"
              (lib.mkIf isLaptop "battery")
              "power-profiles-daemon"
              "systemd-failed-units"
            ];
            "cpu" = {
              "format" = " {usage}%";
              "interval" = 10;
            };
            "memory" = {
              "format" = " {percentage}%";
              "interval" = 10;
            };
            "network" = {
              "format-ethernet" = "󰈀 {ifname}";
              "format-wifi" = "󱚽 {essid} ({signalStrength}%)";
            };
            "custom/mpd" = lib.mkIf enableMpd {
              "return-type" = "string";
              "interval" = 1;
              "exec" = "${homeDir}/.local/scripts/cli.mpd.nowPlaying";
            };
            "battery" = {
              "format-icons" = ["󱊡" "󱊢" "󱊣"];
              "format-charging" = "󰂄 {capacity}%";
              "format" = "{icon} {capacity}%";
              "interval" = "5";
            };
            "power-profiles-daemon" = {
              "format" = "{icon}";
              "format-icons" = {
                "default" = " ";
                "balanced" = " ";
                "performance" = " ";
                "powersave" = " ";
              };
            };
            "systemd-failed-units" = {
              "hide-on-ok" = false;
              "format" = "systemd: 󰀩 {nr_failed}";
              "format-ok" = "systemd:  ";
              "system" = true;
              "user" = true;
            };
          };
        };
        style =
          /*
          css
          */
          ''
            * {
              border: none;
              border-radius: 0;
              font-family: JetBrainsMono Nerd Font, monospace;
              font-size: ${fontsize};
              font-weight: 500;
              min-height: 0;
            }
            window#waybar.background {
              /* transparent background */
              background: rgba(0, 0, 0, 0);
            }
            #workspaces {
              padding: 0px 0px 0px 0px;
            }
            #workspaces button {
              color: ${foreground};
              background-color: ${bg3};
              min-width: 25px;
            }
            #workspaces button.empty {
              color: ${grey1};
              background-color: ${bg3};
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
            #scratchpad {
              background-color: ${blue};
              color: ${bg0};
              padding: 2px 5px;
            }
            #mode {
              padding-left: 10px;
              padding-right: 10px;
              background-color: ${green};
              color: ${bg3};
            }
            #submap {
              padding-left: 10px;
              padding-right: 10px;
              background-color: ${red};
              color: ${bg3};
            }
            #custom-mpd {
              padding-right: 10px;
              padding-left: 10px;
              color: ${foreground};
              background-color: ${bg3};
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
            window#waybar.topBar .modules-center {
              padding: 0 12px;
              color: ${foreground};
              background-color: ${bg3};
            }
            @keyframes blink {
              to {
                color: ${green};
              }
            }
            #tray {
              background: ${bg3};
            }
            #custom-inhibitidle.active {
              color: ${bg0};
              background-color: ${red};
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
            #systemd-failed-units.ok {
              background-color: ${green};
              color: ${bg0};
            }
            #systemd-failed-units.degraded {
              background-color: ${red};
              color: ${bg0};
            }
            #power-profiles-daemon {
              padding-left: 10px;
              padding-right: 10px;
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

            fields=$(mpc -f 'name=%name%\nartist=%artist%\nalbum=%album%\ntitle=%title%\ntime=%time%' | sed 's/^\n//' | head -n 5)
            name=$(echo "$fields" | grep -oP 'name=\K.*')
            artist=$(echo "$fields" | grep -oP 'artist=\K.*')
            album=$(echo "$fields" | grep -oP 'album=\K.*')
            title=$(echo "$fields" | grep -oP 'title=\K.*')
            time=$(echo "$fields" | grep -oP 'time=\K.*')
            status=$(mpc status | sed -n '2p')  # Second line contains the playback status and timing info
            player=$(mpc status | sed -n '3p') # Third line contains volume, repeat, random, etc.

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
