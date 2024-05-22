{
  config,
  pkgs,
  inputs,
  ...
}: {
  services.yabai = {
    enable = true;
    config = {
      layout = "bsp";
      # padding and gaps
      top_padding = 3;
      bottom_padding = 3;
      left_padding = 3;
      right_padding = 3;
      window_gap = 5;
      # mouse
      focus_follows_mouse = "off";
      mouse_follows_focus = "off";
      mouse_modifier = "cmd";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      # appearance
      window_shadow = "off";
      # external_bar = "all:36:0";
    };
    extraConfig = ''
      # automatically focus other window when closing another
      yabai -m signal --add event=window_destroyed action="yabai -m query --windows --window &> /dev/null || yabai -m window --focus mouse"
      yabai -m signal --add event=application_terminated action="yabai -m query --windows --window &> /dev/null || yabai -m window --focus mouse"
      # force some appliactions to behave, mostly those that might be running in the background before yabai starts
      yabai -m rule --add label="Firefox" manage=on
      yabai -m rule --add label="Zscaler" manage=on
      yabai -m rule --add app="qutebrowser" manage=on
    '';
  };
  services.skhd = {
    enable = true;
    package = pkgs.skhd;
    skhdConfig = ''
      # Reload yabai
      cmd + shift - c : launchctl kickstart -k "gui/$\{UID}/org.nixos.yabai"
      # focus window in bsp mode
      cmd - h : yabai -m window --focus west
      cmd - j : yabai -m window --focus south
      cmd - k : yabai -m window --focus north
      cmd - l : yabai -m window --focus east
      # move (warp) windows
      cmd + shift - h : yabai -m window --warp west
      cmd + shift - j : yabai -m window --warp south
      cmd + shift - k : yabai -m window --warp north
      cmd + shift - l : yabai -m window --warp east
      # toggle floating
      cmd + shift - space : yabai -m window --toggle float;\
                      yabai -m window --grid 4:4:1:1:2:2
      # switching spaces
      cmd - 1 : ~/.config/yabai/mac-focus-space-SIP.sh 1
      cmd - 2 : ~/.config/yabai/mac-focus-space-SIP.sh 2
      cmd - 3 : ~/.config/yabai/mac-focus-space-SIP.sh 3
      cmd - 4 : ~/.config/yabai/mac-focus-space-SIP.sh 4
      cmd - 5 : ~/.config/yabai/mac-focus-space-SIP.sh 5
      cmd - 6 : ~/.config/yabai/mac-focus-space-SIP.sh 6
      cmd - 7 : ~/.config/yabai/mac-focus-space-SIP.sh 7
      cmd - 8 : ~/.config/yabai/mac-focus-space-SIP.sh 8
      cmd - 9 : ~/.config/yabai/mac-focus-space-SIP.sh 9
      cmd - 0 : ~/.config/yabai/mac-focus-space-SIP.sh 10

      # move windows to spaces
      # https://github.com/koekeishiya/skhd/issues/75#issuecomment-481656153
      cmd + shift - 0x12 : ~/.config/yabai/mac-move-space-SIP.sh 1
      cmd + shift - 0x13 : ~/.config/yabai/mac-move-space-SIP.sh 2
      cmd + shift - 0x14 : ~/.config/yabai/mac-move-space-SIP.sh 3
      cmd + shift - 0x15 : ~/.config/yabai/mac-move-space-SIP.sh 4
      cmd + shift - 0x17 : ~/.config/yabai/mac-move-space-SIP.sh 5
      cmd + shift - 0x16 : ~/.config/yabai/mac-move-space-SIP.sh 6
      cmd + shift - 0x1A : ~/.config/yabai/mac-move-space-SIP.sh 7
      cmd + shift - 0x1C : ~/.config/yabai/mac-move-space-SIP.sh 8
      cmd + shift - 0x19 : ~/.config/yabai/mac-move-space-SIP.sh 9
      cmd + shift - 0x1D : ~/.config/yabai/mac-move-space-SIP.sh 10
    '';
  };
}
