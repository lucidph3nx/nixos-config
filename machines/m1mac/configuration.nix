{ pkgs, inputs, ... }:

{
  # imports =
  # [
  #   inputs.home-manager.darwinModules.home-manager
  # ];
  users.users.ben = {
    home = "/Users/ben";
  };
  programs.zsh.enable = true;
  environment = {
    shells = [ pkgs.bash pkgs.zsh ];
    loginShell = pkgs.zsh;
    systemPackages = [ pkgs.eza ];
  };
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  fonts.fontDir.enable = true;
  fonts.fonts = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ];})
  ];
  services = {
    nix-daemon.enable = true;
    yabai = {
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
    # spacebar = {
    #   enable = true;
    #   package = pkgs.spacebar;
    #   config = {
    #     title = "off";
    #     clock = "on";
    #     foreground_color = "0xffd3c6aa";
    #     background_color = "0xff2d353b";
    #     clock_format = ''"%Y-%m-%d %H:%M:%S"'';
    #     clock_icon = "XX";
    #     clock_icon_color = "0xff2d353b";
    #     display_separator = "on";
    #     display_separator_icon = "|";
    #     space_icon_strip = "1 2 3 4 5 6 7 8 9 0";
    #     space_icon_color = "0xffa7c080";
    #     space_icon_color_secondary = "0xffdbbc7f";
    #     space_icon_color_tertiary = "0xff7fbbb3";
    #     spaces_for_all_displays = "on";
    #     power = "on";
    #     power_icon_strip = "󰁹 󰚥";
    #     power_icon_color = "0xffe69875";
    #     battery_icon_color = "0xffe69875";
    #     position = "top";
    #     text_font = ''"JetBrains Mono:regular:16.0"'';
    #     icon_font = ''"JetBrains Mono:regular:16.0"'';
    #     height = 35;
    #   };
    # };
    skhd = {
      enable = true;
      package = pkgs.skhd;
      skhdConfig = ''
        # Reload yabai
        cmd + shift - c : yabai --restart-service"
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
      '';
    };
    karabiner-elements.enable = true;
  };
  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
    };
    dock = {
      autohide = true;
      # basically, permanantly hide dock
      autohide-delay = 1000.0;
      orientation = "left";
    };
    menuExtraClock = {
      IsAnalog = false;
      Show24Hour = true;
      ShowAMPM = false;
      ShowSeconds = true;
    };
    spaces = {
      spans-displays = false;
    };
    universalaccess = {
      reduceMotion = true;
      reduceTransparency = true;
    };
    NSGlobalDomain = {
      _HIHideMenuBar = false;
      AppleInterfaceStyle = "Dark";
      AppleICUForce24HourTime = true;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
    };
  };

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users = {
      ben.imports = [
        ./home.nix
      ];
    };
  };
}
