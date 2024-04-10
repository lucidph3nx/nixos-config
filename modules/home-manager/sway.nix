{ config, pkgs, osConfig, ... }:

let theme = import ../themes/theme.nix;
in
{
  wayland.windowManager.sway = let
      # bindings
      super = "Mod4";
      alt = "Mod1";
      pageup = "Prior";
      pagedown = "Next";
      left = "h";
      down = "j";
      up = "k";
      right = "l";
      # scripts
      screenshotutil = "application.grim.screenshotToClipboard";
      emojipicker = "application.rofi.emojipicker";
      runscripts = "application.scripts.launcher";
      calculator = "application.rofi.calculator";
      nvimsessionlauncher = "application.nvim.sessionLauncher";
      applicationlauncher = "application.launcher";
      # applications
      terminal = "kitty";
      browser = "firefox";
      calendar = "firefox --new-window https://calendar.google.com";
      home-assistant = "firefox --new-window https://home-assistant.$SECRET_DOMAIN";
      plex = "firefox --new-window https://plex.$SECRET_DOMAIN";
      filemanager = "lf";
      musicplayer = "kitty ncmpcpp";
      obsidian = "kitty cli.tmux.projectSessioniser /home/ben/documents/obsidian/personal-vault";
      addtoshoppinglist = "home.shoppinglist.addItem";
      openshoppinglist = "firefox --new-window https://www.notion.so/ph3nx/Shopping-List-92d98ac3dc86460285a399c0b1176fc5";
    in
   {
    enable = true;
    config = {
      focus = {
        followsMouse = false;
        mouseWarping = false;
      };
      input = {
        "type:keyboard" = {
          # Te Reo Macrons
          xkb_layout = "nz";
          xkb_variant = "mao";
          # Right Super for macrons
          xkb_options = "lv3:rwin_switch";
          # keyrepeat settings
          repeat_delay = 225;
          repeat_rate = 60;
        };
      };
      fonts = {
        names = [
          "JetBrainsMono Nerd Font Medium"
          "NotoSans"
          "NotoEmoji"
        ];
        size = 10;
      };
      bindkeysToCode = true;
      keybindings = {
        # Motions
        ## Focus Window
        "${super}+${left}" = "focus left";
        "${super}+${down}" = "focus down";
        "${super}+${up}" = "focus up";
        "${super}+${right}" = "focus right";
        ## Move Window
        "${super}+Shift+${left}" = "move left";
        "${super}+Shift+${down}" = "move down";
        "${super}+Shift+${up}" = "move up";
        "${super}+Shift+${right}" = "move right";
        ## Switch Workspaces
        "${super}+Tab" = "workspace back_and_forth";
        "${super}+1" = "workspace number 1";
        "${super}+2" = "workspace number 2";
        "${super}+3" = "workspace number 3";
        "${super}+4" = "workspace number 4";
        "${super}+5" = "workspace number 5";
        "${super}+6" = "workspace number 6";
        "${super}+7" = "workspace number 7";
        "${super}+8" = "workspace number 8";
        "${super}+9" = "workspace number 9";
        "${super}+0" = "workspace number 0";
        # Move Window to Workspace
        "${super}+Shift+1" = "move container to workspace number 1";
        "${super}+Shift+2" = "move container to workspace number 2";
        "${super}+Shift+3" = "move container to workspace number 3";
        "${super}+Shift+4" = "move container to workspace number 4";
        "${super}+Shift+5" = "move container to workspace number 5";
        "${super}+Shift+6" = "move container to workspace number 6";
        "${super}+Shift+7" = "move container to workspace number 7";
        "${super}+Shift+8" = "move container to workspace number 8";
        "${super}+Shift+9" = "move container to workspace number 9";
        "${super}+Shift+0" = "move container to workspace number 0";
        # next window horizontal/vertical
        "${super}+b" = "splith";
        "${super}+v" = "splitv";
        # Toggle current window to be floating
        "${super}+Shift+space" = "floating toggle";
        # Swap focus between tiling and floating windows
        "${super}+${alt}+space" = "focus mode_toggle";
        # Scratchpad
        "${super}+Shift+minus" = "move scratchpad";
        "${super}+minus" = "scratchpad show";
        # Enter resize mode
        "${super}+r" = "mode resize";
        # Enter move mode
        "${super}+m" = "mode move";
        # Window Shortcuts
        "${super}+q" = "kill";
        "${super}+Shift+c" = "reload";
        "${super}+Shift+s" = "exec ${screenshotutil}";
        "${super}+period" = "exec ${emojipicker}";
        "${super}+Space" = "exec ${runscripts}";
        "${super}+c" = "exec ${calculator}";
        "${super}+f" = "exec ${nvimsessionlauncher}";
        # Notifications Center
        "${super}+n" = "exec swaync-client -t -sw";
        "${super}+Shift+n" = "exec swaync-client --close-all && swaync-client --close-panel";
        # Application Shortcuts
        "${alt}+Return" = "exec ${terminal}";
        "${alt}+Space" = "exec ${applicationlauncher}";
        "${alt}+b" = "exec ${browser}";
        "${alt}+c" = "exec ${calendar}";
        "${alt}+h" = "exec ${home-assistant}";
        "${alt}+p" = "exec ${filemanager}";
        "${alt}+m" = "exec ${musicplayer}";
        "${alt}+l" = "exec ${addtoshoppinglist}";
        "${alt}+Shift+l" = "exec ${openshoppinglist}";
        "${alt}+o" = "exec ${obsidian}";
        # Home automation
        "${super}+${pageup}" = "exec home.office.openBlinds";
        "${super}+${pagedown}" = "exec home.office.closeBlinds";
        # Media Controls
        "XF86AudioMute" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioRaiseVolume" = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioPlay" = "playerctl play-pause";
        "XF86AudioStop" = "playerctl stop";
        "XF86AudioNext" = "playerctl next";
        "XF86AudioPrev" = "playerctl previous";
      };
      modes = {
        resize = {
          "${left}" = "resize shrink width 10px";
          "${down}" = "resize grow height 10px";
          "${up}" = "resize shrink height 10px";
          "${right}" = "resize grow width 10px";
          "f" = "fullscreen toggle; mode default";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
        move = {
          "${left}" = "move left 20px";
          "${down}" = "move down 20px";
          "${up}" = "move up 20px";
          "${right}" = "move right 20px";
          "f" = "fullscreen toggle; mode default";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };
      bars = [{
        command = "${pkgs.waybar}/bin/waybar";
      }];
      window = {
        border = 3;
        hideEdgeBorders = "none";
        commands = [
          {
            criteria.app_id = "pavucontrol";
            command = "floating enable, resize set width 500 px height 600 px";
          }
          {
            criteria.instance = "plexamp";
            command = "floating enable, resize set width 300 px height 600 px";
          }
          {
            criteria.app_id = "gedit";
            command = "floating enable, resize set width 800 px height 600 px";
          }
          {
            criteria.app_id = "org.gnome.Calculator";
            command = "floating enable, resize set width 300 px height 500 px";
          }
          {
            criteria.app_id = "ranger-filepicker";
            command = "floating enable, resize set width 900 px height 600 px";
          }
          {
            criteria.app_id = "qute-editor";
            command = "floating enable, resize set width 900 px height 600 px";
          }
        ];
      };
      assigns = {
        "2" = [
          { instance = "teams-for-linux"; }
          { instance = "prospect-mail"; }
          { instance = "discord"; }
          { instance = "webcord"; }
        ];
      };
      floating = {
        border = 3;
        modifier = "${super}";
      };
      colors = let
        active = theme.green;
        inactive = theme.blue;
        foreground = theme.foreground;
        background = theme.background;
        warn = theme.orange;
        danger = theme.red;
      in 
      {
        focused = {
          border = active;
          background = active;
          text = foreground;
          indicator = active;
          child_border = active;
        };
        focused_inactive = {
          border = inactive;
          background = background;
          text = foreground;
          indicator = background;
          child_border = background;
        };
        unfocused = {
          border = inactive;
          background = background;
          text = foreground;
          indicator = background;
          child_border = background;
        };
      };
      gaps = {
        inner = 5;
      };
      startup = [
        {
          # swayidle: lock screen after 30 minutes of inactivity
          # turn off screen after 1 hour of inactivity
          command = ''
            exec swayidle -w \
              timeout 1800 'swaylock -f -c 000000' \
              timeout 3600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
              before-sleep 'swaylock -f -c 000000'
            '';
        }
        {
          # set smart gaps etc if super-ultrawide
          command = "cli.system.setSwayGaps";
          always = true;
        }
        { # Autotiling Sway Extension
          command = "autotiling";
          always = true;
        }
        { # Notification Daemon
          command = "swaync";
          always = true;
        }
        { # Gui App permissions
          command = "${pkgs.polkit}/bin/polkit-agent";
        }
        { # Input remapper
          command = "${pkgs.polkit}/bin/polkit-agent";
        }
        {
          # Many apps have tray icons, so wait for tray to be ready before starting them
          # Then autostart all XDG autostart .desktop files using dex
          command = "gdbus wait --session org.kde.StatusNotifierWatcher && dex -a -s ~/.config/autostart/";
        }
      ];
    };
    extraConfig = ''
      ## Exit menu
      set $mode_exit "<span> \
          <span> Lock</span> <span foreground='$danger'>(<b>l</b>)</span> \
          <span>󰍃 Logout</span> <span foreground='$danger'>(<b>L</b>)</span> \
          <span>󰜉 Reboot</span> <span foreground='$danger'>(<b>r</b>)</span> \
          <span>󰐥 Shutdown</span> <span foreground='$danger'>(<b>s</b>)</span> </span>"
      mode --pango_markup $mode_exit {
          bindsym --to-code {
              l exec swaylock, mode "default"
              Shift+l exec loginctl terminate-user $USER, mode "default"
              r exec systemctl reboot, mode "default"
              s exec systemctl poweroff, mode "default"
              Escape mode "default"
          }
          bindsym Escape mode "default
      }
      # Enter Exit mode
      bindsym --to-code $super+Shift+e mode $mode_exit
      bindsym --release $super+Shift+e exec sleep 3 && swaymsg mode "default"
    '';
  };
  home.sessionVariables = {
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
  };
  home.packages = with pkgs; [
    swaybg
    swayidle
    swaylock
    swaynotificationcenter
    autotiling
    polkit
    dex
  ];
  # home.file = {
    # ".config/sway/config".source              = ./files/sway-config;
    # ".config/sway/navi/config".source         = ./files/sway-navi-config;
    # ".config/sway/scripts/set_gaps.sh".source = ./files/sway-script-setgaps;
  # };
  # my scripts relevant to sway
  home.sessionPath = ["$HOME/.local/scripts"];
  home.file.".local/scripts/cli.system.setSwayGaps" = {
    text = ''
      #!/bin/bash
      width=$(swaymsg -t get_outputs | jq '.[0].rect.width' | xargs printf "%.0f\n")
      # Check if running in super-ultrawide
      if [ $width -gt 5000 ]; then
        swaymsg smart_gaps inverse_outer
        swaymsg gaps horizontal $(($width/4))
        swaymsg gaps horizontal all set $(($width/4))
      else
        swaymsg smart_gaps off
        swaymsg gaps horizontal 0
        swaymsg gaps horizontal all set 0
      fi
    '';
  };
}
