{ config, pkgs, osConfig, ... }:

let 
  homeDir = config.home.homeDirectory;
  browserNewWindow = "firefox --new-window";
in
with config.theme;
{
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
          "custom/office-temp"
          "custom/office-humidity"
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
        "custom/office-temp" = {
          "return-type" = "string";
          "interval" = 60;
          "format" = " {}";
          "exec" = "${homeDir}/.local/scripts/cli.home.office.getTemperature";
          "on-click" = "${browserNewWindow} https://home-assistant.$SECRET_DOMAIN/lovelace/default_view";
        };
        "custom/office-humidity" = {
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
  };
  home.file = {
    # ".config/waybar/config".source            = ./files/waybar-config;
    ".config/waybar/style.css".source         = ./files/waybar-style;
  };
}
