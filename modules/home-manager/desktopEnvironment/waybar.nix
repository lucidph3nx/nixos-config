{ config, pkgs, lib, ... }:

let 
  homeDir = config.home.homeDirectory;
  browserNewWindow = "firefox --new-window";
  enableHomeAutomation = config.homeManagerModules.homeAutomation.enable;
in
with config.theme;
{
  options = {
    homeManagerModules.waybar = {
      enable = lib.mkEnableOption "enables waybar";
      # TODO: maybe an option here which enables the output = "DP-3" below
      # also maybe switches the hyperland workspaces on?
    };
  };
  config = lib.mkIf config.homeManagerModules.waybar.enable {
    programs.waybar = {
      enable = true;
      systemd.target = "sway-session.target";
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 25;
          # output = "DP-3";
          modules-left = [
            "sway/workspaces"
            "sway/scratchpad"
            "sway/mode"
            # "hyprland/workspaces"
            "mpd"
          ];
          modules-center = [];
          modules-right = [
            "tray"
            "pulseaudio"
            "custom/pulseaudio-cycle"
            (lib.mkIf enableHomeAutomation "custom/office-temp")
            (lib.mkIf enableHomeAutomation "custom/office-humidity")
            "custom/notification"
            "network"
            "battery"
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
          "wlr/taskbar" = {
            "format" = "{icon}";
            "icon-size" = 16;
            "tooltip-format" = "{title}";
            "on-click" = "activate";
            "on-click-middle" = "minimize";
            "on-click-right" = "close";
          };
          "mpd" = {
            "format" = "{stateIcon} {artist} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ";
            "format-disconnected" = "";
            "format-stopped" = "";
            "interval" = 10;
            "state-icons" = {
              "paused" = "";
              "playing" = "";
            };
            "tooltip-format" = "MPD (connected)";
            "tooltip-format-disconnected" = "MPD (disconnected)";
            "on-click" = "kitty ncmpcpp";
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
          "pulseaudio" = {
            "format" = "{volume}%";
            "on-click" = "pavucontrol";
          };
          "custom/pulseaudio-cycle" = {
            "return-type" = "json";
            "exec-on-event" = true;
            "interval" = 1;
            "format" = "{icon}";
            "format-icons" = {
                "0" = "󰋋";
                "1" = "󰓃" ;
            };
            "exec" = "pactl --format=json list sinks | jq -cM --unbuffered \"map(select(.name == \\\"$(pactl get-default-sink)\\\"))[0] | {alt:(.\\\"index\\\")}\"";
            "exec-if" = "sleep 0.5"; # Give enough time for `pactl get-default-sink` to update
            "on-click" = "pactl --format=json list sinks short | jq -cM --unbuffered \"[.[].name] | .[((index(\\\"$(pactl get-default-sink)\\\")+1)%length)]\" | xargs pactl set-default-sink";
            };
          "custom/clock" = {
            "interval" = 1;
            "exec" = "date +'%F %T'";
            "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
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
      };
      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: JetBrainsMono Nerd Font, monospace;
          font-size: 18px;
          font-weight: 500; 
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
        #workspaces button.focused {
          background-color: ${green};
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
          background: ${blue};
          color: ${bg0};
        }
        #workspaces button {
          color: ${foreground};
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
        #mpd {
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
          background-color: ${green};
        }
        @keyframes blink {
          to {
            color: ${green};
          }
        }
        #tray {
          background: ${bg0};
        }
        #pulseaudio {
            padding-right: 0px;
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
  };
}
