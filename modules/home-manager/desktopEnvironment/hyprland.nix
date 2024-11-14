{
  config,
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
      wallpaperResolution = lib.mkOption {
        type = lib.types.str;
        default = "5120x1440";
        description = "Resolution of the wallpaper";
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
      # applications
      terminal = "kitty";
      browser = "firefox";
      calendar = "firefox --new-window https://calendar.google.com";
      home-assistant = "firefox --new-window https://home-assistant.$SECRET_DOMAIN";
      plex = "firefox --new-window https://plex.$SECRET_DOMAIN";
      filemanager = "kitty lf";
      musicplayer = "kitty ncmpcpp";
      obsidian = "kitty ${homeDir}/.local/scripts/cli.tmux.projectSessioniser ${homeDir}/documents/obsidian/personal-vault";
      addtoshoppinglist = "${homeDir}/.local/scripts/home.shoppinglist.addItem";
      openshoppinglist = "firefox --new-window https://www.notion.so/ph3nx/Shopping-List-92d98ac3dc86460285a399c0b1176fc5";
    in {
      enable = true;
      settings = {
        exec-once = let resolution = config.homeManagerModules.hyprland.wallpaperResolution; in [
          "swaync"
          (lib.mkIf (config.theme.name == "everforest") "swaybg -i ${homeDir}/.config/wallpaper_everforest-${resolution}.png --mode fill")
          (lib.mkIf (config.theme.name == "github-light") "swaybg -i ${homeDir}/.config/wallpaper_github_light-${resolution}.png --mode fill")
          # "swaybg --color ${builtins.substring 1 6 (theme.bg_dim)}"
          "hypridle"
          "waybar"
          "steam -silent" # couldn't figure out xdg-autostart
          "${homeDir}/.local/scripts/game.inputRemapper.defaults"
        ];
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
          drop_shadow = "no";
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
            # "workspaces,0" # disable workspace animations
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
          swallow_exception_regex = "^(lf)$";
        };
        windowrulev2 = [
          "workspace 2 silent,class:(Prospect Mail)"
          "workspace 2 silent,class:(teams-for-linux)"
          "workspace 2 silent,class:(WebCord)"
          "float, class:(Waydroid)"
          "center, class:(Waydroid)"
        ];
        windowrule = [
          "size, 480 800 class:(Waydroid)"
        ];
        monitor = [
          ",preferred,auto,auto"
        ];
        bind = [
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
          "SUPER, 0, workspace, 0"
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
          "SUPER SHIFT, 0, movetoworkspacesilent, 0"
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
          # ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
          # ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
          ", XF86AudioStop, exec, ${pkgs.playerctl}/bin/playerctl stop"
          ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
          ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
        ];
        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
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
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "hyprctl dispatch exec hyprlock";
        };
        listener = [
          {
            # lock screen after 30 minutes inactivity
            timeout = 1800;
            on-timeout = "hyprctl dispatch exec hyprlock";
          }
          {
            # turn off screen after 1 hour of inactivity
            timeout = 3600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
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
  };
}
