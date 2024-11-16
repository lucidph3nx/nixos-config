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
              (lib.mkIf enableMpd "mpd")
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
    };
  }
