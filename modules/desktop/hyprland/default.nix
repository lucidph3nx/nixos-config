{
  config,
  lib,
  pkgs,
  ...
}: let
  homeDir = config.home-manager.users.ben.home.homeDirectory;
  theme = config.theme;
in {
  imports = [
    ./idle.nix
    ./scripts.nix
    ./hyprlock.nix
  ];
  options = {
    nx.desktop.hyprland = {
      enable =
        lib.mkEnableOption "enable the Hyprland desktop module"
        // {
          default = true;
        };
      disableWorkspaceAnimations = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "disables workspace animations";
      };
    };
  };
  config = {
    # enable for system
    programs.hyprland.enable = true;
    # configure for user
    home-manager.users.ben.wayland.windowManager.hyprland = let
      # scripts
      emojipicker = "${homeDir}/.local/scripts/application.rofi.emojipicker";
      runscripts = "${homeDir}/.local/scripts/application.scripts.launcher";
      calculator = "${homeDir}/.local/scripts/application.rofi.calculator";
      nvimsessionlauncher = "${homeDir}/.local/scripts/application.nvim.sessionLauncher";
      applicationlauncher = "${homeDir}/.local/scripts/application.launcher";
      toggleTouchpad = "${homeDir}/.local/scripts/system.inputs.toggleTouchpad";
      # applications
      terminal = "kitty";
      browser = config.nx.programs.defaultWebBrowserSettings.cmd;
      newwindow = config.nx.programs.defaultWebBrowserSettings.newWindowCmd;
      calendar = "${newwindow} https://calendar.google.com";
      filemanager = "${terminal} lf";
      musicplayer = "${terminal} ncmpcpp";
      obsidian = "${terminal} ${homeDir}/.local/scripts/cli.tmux.projectSessioniser ${homeDir}/documents/obsidian";
      nixosconfig = "${terminal} ${homeDir}/.local/scripts/cli.tmux.projectSessioniser ${homeDir}/code/nixos-config";
      addtoshoppinglist = "${homeDir}/.local/scripts/home.shoppinglist.addItem";
      openshoppinglist = "${newwindow} https://www.notion.so/ph3nx/Shopping-List-92d98ac3dc86460285a399c0b1176fc5";
      # configuration
      enableAudioControls = config.nx.externalAudio.enable == false;
    in {
      enable = true;
      settings = {
        exec-once = let
          resolution = config.nx.desktop.wallpaper.resolution;
        in [
          "${pkgs.swaynotificationcenter}/bin/swaync"
          (lib.mkIf config.nx.desktop.wallpaper.enable "swaybg -i ${homeDir}/.config/wallpaper-${resolution}.png --mode fill")
          # (lib.mkIf (config.theme.name == "everforest") "swaybg -i ${homeDir}/.config/wallpaper_everforest-${resolution}.png --mode fill")
          # (lib.mkIf (config.theme.name == "github-light") "swaybg -i ${homeDir}/.config/wallpaper_github_light-${resolution}.png --mode fill")
          # "swaybg --color ${builtins.substring 1 6 (theme.bg_dim)}"
          "hypridle"
          (lib.mkIf (config.nx.isLaptop == false) "steam -silent") # couldn't figure out xdg-autostart
          "${homeDir}/.local/scripts/game.inputRemapper.defaults"
          # default to 70% brightness
          (lib.mkIf config.nx.isLaptop "${pkgs.brightnessctl}/bin/brightnessctl s 70%")
          # default to keyboard backlight off
          (lib.mkIf config.nx.isLaptop "${pkgs.brightnessctl}/bin/brightnessctl --device='asus::kbd_backlight' set 0")
          ".local/scripts/cli.hyprland.switchWorkspaceOnWindowClose"
          "waybar"
        ];
        debug = {
          disable_logs = false;
        };
        ecosystem = {
          # don't show update notifications each boot
          no_update_news = true;
        };
        exec = [
          # restart waybar, if for some reason it died
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
          workspace_swipe = lib.mkIf config.nx.isLaptop true;
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
        };
        cursor = {
          inactive_timeout = 5;
        };
        decoration = {
          rounding = 5;
          blur.enabled = true;
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
            (lib.mkIf (config.nx.desktop.hyprland.disableWorkspaceAnimations != true)
              "workspaces,1,1, myBezier")
            (lib.mkIf (config.nx.desktop.hyprland.disableWorkspaceAnimations == true)
              "workspaces,0")
          ];
        };
        dwindle = {
          pseudotile = "yes";
          preserve_split = "yes";
          force_split = 2;
        };
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          vrr = 1;
          # when opening another program from terminal, swallow the terminal
          enable_swallow = true;
          swallow_regex = "^(kitty|lf)$";
          swallow_exception_regex = "^(wev)$";
        };
        device = [
          {
            # reduce touchpad sensitivity
            name = "asup1415:00-093a:300c-touchpad";
            sensitivity = 0.5;
          }
        ];
        windowrulev2 = [
          # sometimes chromium thinks its fine to open in a tiny window
          "tile, class:(Chromium-browser)"
          "tile, class:^(Minecraft.*)$"
        ];
        monitor = [
          ",preferred,auto,auto"
        ];
        bindrt = [
          # hide waybar on SUPER_L keyup (actually resets which loads it as hidden)
          "SUPER, SUPER_L, exec, pkill -SIGUSR2 waybar"
        ];
        bind = [
          # show waybar on SUPER_L keydown
          ", SUPER_L, exec, pkill -SIGUSR1 waybar"
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
          "SUPER, period, exec, ${emojipicker}"
          "SUPER, Space, exec, ${runscripts}"
          "SUPER, c, exec, ${calculator}"
          "SUPER, f, exec, ${nvimsessionlauncher}"
          "SUPER SHIFT, F, fullscreen"
          "SUPER, s, exec, ${homeDir}/.local/scripts/cli.system.suspend"
          "SUPER, i, exec, ${homeDir}/.local/scripts/cli.system.inhibitIdle toggle"
          # Notification Center
          "SUPER, n, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw"
          "SUPER SHIFT, N, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client --close-all && ${pkgs.swaynotificationcenter}/bin/swaync-client --close-panel"
          # application shortcuts
          "ALT, Return, exec, ${terminal}"
          "AlT, Space, exec, ${applicationlauncher}"
          "ALT, a, exec, anki"
          "ALT, b, exec, ${browser}"
          "ALT, c, exec, ${calendar}"
          "ALT, f, exec, ${filemanager}"
          "ALT, m, exec, ${musicplayer}"
          "ALT, l, exec, ${addtoshoppinglist}"
          "ALT SHIFT, l, exec, ${openshoppinglist}"
          "ALT, o, exec, ${obsidian}"
          "ALT, n, exec, ${nixosconfig}"
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
          (lib.mkIf config.nx.isLaptop ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl s +10%")
          (lib.mkIf config.nx.isLaptop ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 10%-")
          # on my asus laptop, one of the function keys presses Super_L+p for some reason for touchpad disable
          (lib.mkIf config.nx.isLaptop "SUPER, p, exec, ${toggleTouchpad}")
          # print screen
          ", Print, exec, ${homeDir}/.local/scripts/application.grim.fullScreenshotToFile"
        ];
        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];
        # bindl = [
        #   ", switch:on:Lid Switch, exec, ${homeDir}/.local/scripts/cli.system.suspend"
        # ];
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
    home-manager.users.ben.home.packages = with pkgs; [
      dex
      grim
      slurp
      swaybg
      wl-clipboard
      (lib.mkIf config.nx.isLaptop brightnessctl)
    ];
  };
}
