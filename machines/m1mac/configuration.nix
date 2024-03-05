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
