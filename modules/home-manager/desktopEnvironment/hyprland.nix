{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}: let
  homeDir = config.home.homeDirectory;
  theme = config.theme;
in {
  options = {
    homeManagerModules.hyprland = {
      enable = lib.mkEnableOption "enables hyprland";
      disableWorkspaceAnimations = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "disables workspace animations";
      };
      lockTimeout.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "whether to lock the screen due to idle";
      };
      lockTimeout.duration = lib.mkOption {
        type = lib.types.int;
        # default 30 minutes
        default = 1800;
        description = "time before locking the screen";
      };
      screenTimeout.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "whether to turn off the screen due to idle";
      };
      screenTimeout.duration = lib.mkOption {
        type = lib.types.int;
        # default 1 hour
        default = 3600;
        description = "time before turning off the screen";
      };
      suspendTimeout.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "whether to suspend the system due to idle";
      };
      suspendTimeout.duration = lib.mkOption {
        type = lib.types.int;
        # default 2 hours
        default = 7200;
        description = "time before suspending the system";
      };
    };
  };
  config = lib.mkIf config.homeManagerModules.hyprland.enable {
    wayland.windowManager.hyprland = let
      # scripts
      screenshotutil = "${homeDir}/.local/scripts/application.grim.screenshotToClipboard";
      emojipicker = "${homeDir}/.local/scripts/application.rofi.emojipicker";
      runscripts = "${homeDir}/.local/scripts/application.scripts.launcher";
      calculator = "${homeDir}/.local/scripts/application.rofi.calculator";
      nvimsessionlauncher = "${homeDir}/.local/scripts/application.nvim.sessionLauncher";
      applicationlauncher = "${homeDir}/.local/scripts/application.launcher";
      toggleTouchpad = "${homeDir}/.local/scripts/system.inputs.toggleTouchpad";
      # applications
      terminal = "kitty";
      browser = "qutebrowser";
      newwindow = "${browser} --target window";
      # browser = "firefox";
      # newwindow = "${browser} --new-window";
      calendar = "${newwindow} https://calendar.google.com";
      home-assistant = "${newwindow} https://home-assistant.$SECRET_DOMAIN";
      plex = "${newwindow} https://plex.$SECRET_DOMAIN";
      filemanager = "kitty lf";
      musicplayer = "kitty ncmpcpp";
      obsidian = "kitty ${homeDir}/.local/scripts/cli.tmux.projectSessioniser ${homeDir}/documents/obsidian";
      addtoshoppinglist = "${homeDir}/.local/scripts/home.shoppinglist.addItem";
      openshoppinglist = "${newwindow} https://www.notion.so/ph3nx/Shopping-List-92d98ac3dc86460285a399c0b1176fc5";
      # configuration
      enableAudioControls = osConfig.nixModules.externalAudio.enable == false;
    in {
      enable = true;
      settings = {
        exec-once = let
          resolution = config.homeManagerModules.wallpaper.resolution;
        in [
          "swaync"
          (lib.mkIf config.homeManagerModules.wallpaper.enable "swaybg -i ${homeDir}/.config/wallpaper-${resolution}.png --mode fill")
          # (lib.mkIf (config.theme.name == "everforest") "swaybg -i ${homeDir}/.config/wallpaper_everforest-${resolution}.png --mode fill")
          # (lib.mkIf (config.theme.name == "github-light") "swaybg -i ${homeDir}/.config/wallpaper_github_light-${resolution}.png --mode fill")
          # "swaybg --color ${builtins.substring 1 6 (theme.bg_dim)}"
          "hypridle"
          (lib.mkIf (osConfig.nixModules.isLaptop == false) "steam -silent") # couldn't figure out xdg-autostart
          "${homeDir}/.local/scripts/game.inputRemapper.defaults"
          # default to 70% brightness
          (lib.mkIf osConfig.nixModules.isLaptop "${pkgs.brightnessctl}/bin/brightnessctl s 70%")
          # default to keyboard backlight off
          (lib.mkIf osConfig.nixModules.isLaptop "${pkgs.brightnessctl}/bin/brightnessctl --device='asus::kbd_backlight' set 0")
          ".local/scripts/cli.hyprland.switchWorkspaceOnWindowClose"
          "waybar"
          # ags overview
          # "ags run"
        ];
        debug = {
          disable_logs = false;
        };
        exec = [
          "pkill waybar && hyprctl dispatch exec waybar"
          "${homeDir}/.local/scripts/cli.system.setHyprGaps"
        ];
        input = {
          # Te Reo Macrons
          kb_layout = "nz";
          kb_variant = "mao";
          kb_options = "lv3:rwin_switch";
          # keyrepeat settings
          repeat_delay = "225";
          repeat_rate = "60";
          follow_mouse = 2;
          sensitivity = 0;
          touchpad = {
            # feels right for a touchpad
            natural_scroll = true;
          };
        };
        gestures = {
          workspace_swipe = lib.mkIf osConfig.nixModules.isLaptop true;
        };
        general = {
          gaps_in = 5;
          gaps_out = 5;
          border_size = 3;
          # these substring functions are to remove the '#' from the hex color
          # "col.active_border" = "rgba(${builtins.substring 1 6 (theme.green)}ff) rgba(${builtins.substring 1 6 (theme.blue)}ff) 45deg";
          # crazy rainbow border 🌈❤️
          "col.active_border" = "rgba(${builtins.substring 1 6 (theme.red)}ff) rgba(${builtins.substring 1 6 (theme.orange)}ff) rgba(${builtins.substring 1 6 (theme.yellow)}ff) rgba(${builtins.substring 1 6 (theme.green)}ff) rgba(${builtins.substring 1 6 (theme.aqua)}ff) rgba(${builtins.substring 1 6 (theme.blue)}ff) rgba(${builtins.substring 1 6 (theme.purple)}ff) 45deg";
          "col.inactive_border" = "rgba(${builtins.substring 1 6 (theme.bg2)}ff)";
          layout = "dwindle"; #TODO: figure out hy3
          # cursor_inactive_timeout = 5;
        };
        cursor = {
          inactive_timeout = 5;
        };
        decoration = {
          rounding = 0;
          blur.enabled = false;
          shadow = {
            enabled = false;
          };
        };
        bezier = [
          "myBezier,0.05,0.9,0.1,1.0"
          "linear,0,0,1,1"
        ];
        animations = {
          enabled = true;
          animation = [
            "windows, 1, 2, myBezier"
            "windowsOut, 1, 1, myBezier, popin 90%"
            "windowsIn, 1, 1, myBezier, popin 90%"
            "border, 1, 2, default"
            "borderangle, 1, 50, linear, loop"
            "fade, 1, 2, default"
            (lib.mkIf (config.homeManagerModules.hyprland.disableWorkspaceAnimations != true)
              "workspaces,1,1, myBezier")
            (lib.mkIf (config.homeManagerModules.hyprland.disableWorkspaceAnimations == true)
              "workspaces,0")
          ];
        };
        dwindle = {
          pseudotile = "yes";
          preserve_split = "yes";
          force_split = 2;
        };
        master = {
          allow_small_split = true;
          special_scale_factor = ".80";
          mfact = ".45";
          orientation = "center";
          inherit_fullscreen = false;
          always_center_master = false;
        };
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          vrr = 1;
          # when opening another program from terminal, swallow the terminal
          enable_swallow = true;
          swallow_regex = "^(kitty)$";
          swallow_exception_regex = "^(lf|wev|qutebrowser)$";
        };
        windowrulev2 = [
          "workspace 2 silent,class:(Prospect Mail)"
          "workspace 2 silent,class:(teams-for-linux)"
          "workspace 2 silent,class:(WebCord)"
          "float, class:(Waydroid)"
          "center, class:(Waydroid)"
          # popout nvim editor for qutebrowser
          "float, class:(qute-editor)"
          "size 800 480, class:(qute-editor)"
          # popout lf file picker for qutebrowser
          "float, class:(qute-filepicker)"
          "size 800 480, class:(qute-filepicker)"
          "float, title:darktable starting" # darktable splash screen
          "size 480 800, class:(Waydroid)"
        ];
        monitor = [
          ",preferred,auto,auto"
        ];
        layerrule = [
          # disable animations for AGS
          "noanim, gtk-layer-shell"
        ];
        bindrt = [
          # hide ags overview on SUPER_L keyup
          "SUPER, SUPER_L, exec, ags request -i astal hide"
        ];
        bind = [
          # show ags overview on SUPER_L keydown
          ", SUPER_L, exec, ags request -i astal show"
          # Motions
          # focus window
          "SUPER, h, movefocus, l"
          "SUPER, j, movefocus, d"
          "SUPER, k, movefocus, u"
          "SUPER, l, movefocus, r"
          # move window
          "SUPER SHIFT, H, movewindow, l"
          "SUPER SHIFT, J, movewindow, d"
          "SUPER SHIFT, K, movewindow, u"
          "SUPER SHIFT, L, movewindow, r"
          # switch workspace
          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 5"
          "SUPER, 6, workspace, 6"
          "SUPER, 7, workspace, 7"
          "SUPER, 8, workspace, 8"
          "SUPER, 9, workspace, 9"
          # move active window to workspace
          "SUPER SHIFT, 1, movetoworkspacesilent, 1"
          "SUPER SHIFT, 2, movetoworkspacesilent, 2"
          "SUPER SHIFT, 3, movetoworkspacesilent, 3"
          "SUPER SHIFT, 4, movetoworkspacesilent, 4"
          "SUPER SHIFT, 5, movetoworkspacesilent, 5"
          "SUPER SHIFT, 6, movetoworkspacesilent, 6"
          "SUPER SHIFT, 7, movetoworkspacesilent, 7"
          "SUPER SHIFT, 8, movetoworkspacesilent, 8"
          "SUPER SHIFT, 9, movetoworkspacesilent, 9"
          # floating
          "SUPER SHIFT, space, togglefloating"
          # example special workspace TODO more
          "SUPER, X, togglespecialworkspace, magic"
          "SUPER SHIFT, X, movetoworkspacesilent, special:magic"
          # scroll through existing workspaces
          "SUPER, mouse_down, workspace, e+1"
          "SUPER, mouse_up, workspace, e-1"
          # window shortcuts
          "SUPER, q, killactive"
          "SUPER SHIFT, C, exec, hyprctl reload"
          "SUPER SHIFT, S, exec, ${screenshotutil}"
          "SUPER, period, exec, ${emojipicker}"
          "SUPER, Space, exec, ${runscripts}"
          "SUPER, c, exec, ${calculator}"
          "SUPER, f, exec, ${nvimsessionlauncher}"
          "SUPER SHIFT, F, fullscreen"
          "SUPER, s, exec, ${homeDir}/.local/scripts/cli.system.suspend"
          "SUPER, i, exec, ${homeDir}/.local/scripts/cli.system.inhibitIdle toggle"
          ", switch:on:Lid Switch, exec, ${homeDir}/.local/scripts/cli.system.suspend"
          # Notification Center
          "SUPER, n, exec, swaync-client -t -sw"
          "SUPER SHIFT, N, exec, swaync-client --close-all && swaync-client --close-panel"
          # application shortcuts
          "ALT, Return, exec, ${terminal}"
          "AlT, Space, exec, ${applicationlauncher}"
          "ALT, a, exec, anki"
          "ALT, b, exec, ${browser}"
          "ALT, c, exec, ${calendar}"
          "ALT, h, exec, ${home-assistant}"
          "ALT, f, exec, ${filemanager}"
          "ALT, p, exec, ${plex}"
          "ALT, m, exec, ${musicplayer}"
          "ALT, l, exec, ${addtoshoppinglist}"
          "ALT SHIFT, l, exec, ${openshoppinglist}"
          "ALT, o, exec, ${obsidian}"
          # media controls
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          (lib.mkIf enableAudioControls ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+")
          (lib.mkIf enableAudioControls ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-")
          ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
          ", Pause, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
          ", Scroll_Lock, exec, ${pkgs.playerctl}/bin/playerctl stop" # this is fn+k on my asus laptop
          ", XF86AudioStop, exec, ${pkgs.playerctl}/bin/playerctl stop"
          ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
          ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
          (lib.mkIf osConfig.nixModules.isLaptop ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl s +10%")
          (lib.mkIf osConfig.nixModules.isLaptop ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 10%-")
          # on my asus laptop, one of the function keys presses Super_L+p for some reason for touchpad disable
          (lib.mkIf osConfig.nixModules.isLaptop "SUPER, p, exec, ${toggleTouchpad}")
          # print screen
          ", Print, exec, ${homeDir}/.local/scripts/application.grim.fullScreenshotToFile"
        ];
        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];
        bindl = [
          ", switch:on:Lid Switch, exec, systemctl suspend"
        ];
        env = [
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "GDK_BACKEND,wayland,x11"
          "SDL_VIDEODRIVER,wayland"
          "_JAVA_AWT_WM_NONREPARENTING,1"
          "QT_QPA_PLATFORM,wayland"
        ];
      };
      extraConfig = ''
        # resize submap (with auto reset after 10 sec)
        bind=SUPER,R,exec,sleep 10 && hyprctl dispatch submap reset
        bind=SUPER,R,submap,resize
        submap=resize
        binde=,h,resizeactive,-10 0
        binde=,j,resizeactive,0 10
        binde=,k,resizeactive,0 -10
        binde=,l,resizeactive,10 0
        bind=,escape,submap,reset
        submap=reset
        # exit submap (with auto reset after 3 sec)
        bind=SUPER SHIFT,E,exec,sleep 3 && hyprctl dispatch submap reset
        bind=SUPER SHIFT,E,submap,exit
        submap=exit
        # lock
        binde=,l,exec, hyprlock
        # logout
        bind=SHIFT,L,exec, loginctl terminate-user $USER
        # shutdown
        binde=,s,exec, systemctl poweroff
        # reboot
        binde=,r,exec, systemctl reboot
        bind=,escape,submap,reset
        submap=reset
      '';
      systemd = {
        enable = true;
      };
      xwayland.enable = true;
      plugins = [
        # pkgs.hyprlandPlugins.hy3
      ];
    };
    services.hypridle = let
      lockTimeout = config.homeManagerModules.hyprland.lockTimeout.enable;
      screenTimeout = config.homeManagerModules.hyprland.screenTimeout.enable;
      suspendTimeout = config.homeManagerModules.hyprland.suspendTimeout.enable;
      lockTimeoutDuration = config.homeManagerModules.hyprland.lockTimeout.duration;
      screenTimeoutDuration = config.homeManagerModules.hyprland.screenTimeout.duration;
      suspendTimeoutDuration = config.homeManagerModules.hyprland.suspendTimeout.duration;
    in {
      enable = true;
      settings = {
        general = {
          lock_cmd = "hyprctl dispatch exec hyprlock";
        };
        listener = [
          (lib.mkIf lockTimeout {
            timeout = lockTimeoutDuration;
            on-timeout = "hyprctl dispatch exec hyprlock";
          })
          (lib.mkIf screenTimeout {
            timeout = screenTimeoutDuration;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          })
          (lib.mkIf suspendTimeout {
            timeout = suspendTimeoutDuration;
            on-timeout = "systemctl suspend";
            on-resume = "hyprctl dispatch exec hyprlock";
          })
        ];
      };
    };
    home.packages = with pkgs; [
      dex
      grim
      slurp
      swaybg
      swaynotificationcenter
      wl-clipboard
    ];
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
    home.file.".local/scripts/system.inputs.toggleTouchpad" = lib.mkIf osConfig.nixModules.isLaptop {
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
}
