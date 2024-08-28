{
  config,
  pkgs,
  lib,
  ...
}: let
  browserNewWindow = "firefox --new-window";
  enableAudio = config.homeManagerModules.pipewire-utils.enable;
  enableHomeAutomation = config.homeManagerModules.homeAutomation.enable;
  enableMpd = config.homeManagerModules.mpd.enable;
  enableHyprland = config.homeManagerModules.hyprland.enable;
  enableSway = config.homeManagerModules.sway.enable;
  mouseBattery = config.homeManagerModules.waybar.mouseBattery;
  homeDir = config.home.homeDirectory;
in
  with config.theme; {
    options = {
      homeManagerModules.waybar = {
        enable = lib.mkEnableOption "enables waybar";
        displayportOnly = lib.mkEnableOption "only show waybar on DP-3";
        mouseBattery = lib.mkEnableOption "show mouse battery via opernrazer";
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
            height = 33;
            output = lib.mkIf config.homeManagerModules.waybar.displayportOnly "DP-3";
            modules-left = [
              (lib.mkIf enableSway "sway/workspaces")
              (lib.mkIf enableSway "sway/scratchpad")
              (lib.mkIf enableSway "sway/mode")
              (lib.mkIf enableHyprland "hyprland/workspaces")
              (lib.mkIf enableHyprland "hyprland/submap")
              (lib.mkIf enableMpd "mpd")
            ];
            modules-center = [];
            modules-right = [
              "tray"
              (lib.mkIf mouseBattery "custom/mouse-battery")
              (lib.mkIf enableAudio "custom/audio-cycle")
              (lib.mkIf enableAudio "pulseaudio")
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
            "mpd" = lib.mkIf enableMpd {
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
            "pulseaudio" = lib.mkIf enableAudio {
              "format" = "{volume}%";
              "on-click" = "qpwgraph";
            };
            "custom/audio-cycle" = lib.mkIf enableAudio {
              "return-type" = "json";
              "exec-on-event" = true;
              "interval" = 1;
              "format" = "{alt}";
              "exec" = "${homeDir}/.local/scripts/cli.audio.getOutput";
              "exec-if" = "sleep 0.5"; # Give enough time for script to get output
              "on-click" = "${homeDir}/.local/scripts/system.audio.switchOutput";
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
              "return-type" = "string";
              "interval" = 60;
              "exec" = "polychromatic-cli -d mouse -k | grep Battery | sed 's/[^0-9]*//g'";
              "format" = "󰍽 {}%";
            };
            "network" = {
              # don't show when on ethernet
              "format-ethernet" = "";
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
          /* for hyprland its active instead of focused*/
          #workspaces button.active {
            background-color: ${green};
            color: ${bg0};
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
              padding-left: 0px;
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
