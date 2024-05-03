{ config, pkgs, lib, ... }:

{
  options = {
    homeManagerModules.input-remapper.enable =
      lib.mkEnableOption "enables input-remapper";
  };
  config = lib.mkIf config.homeManagerModules.input-remapper.enable {
    home.packages = with pkgs; [ input-remapper ];
    
    # input-remapper configuration
    home.file.".config/input-remapper-2/config.json" = {
      text = ''
        {
          "version": "2.0.1",
          "autoload": {
            "Razer Razer DeathAdder V3 Pro": "default"
          },
          "macros": {
            "keystroke_sleep_ms": 10
          },
          "gamepad": {
            "joystick": {
              "non_linearity": 4,
              "pointer_speed": 80,
              "left_purpose": "none",
              "right_purpose": "none",
              "x_scroll_speed": 2,
              "y_scroll_speed": 0.5
            }
          }
        }
      '';
    };
    # xmodmap file
    home.file.".config/input-remapper-2/xmodmap" = {
      source = ./file/input-remapper-xmodmap;
    };
    # startup command for sway
    wayland.windowManager.sway.config.startup = [
      {
        command = "input-remapper-control --command autoload";
      }
    ];

    # profiles
    # DeathAdder V3 Pro - default
    home.file."config/input-remapper-2/presets/Razer Razer DeathAdder V3 Pro/apex-legends.json" = {
      text = ''
        [
          {
            "input_combination": [
              {
                "type": 1,
                "code": 275,
                "origin_hash": "75dcd3ec37be26ef3b32ef821e4c5fc7"
              }
            ],
            "target_uinput": "keyboard",
            "output_symbol": "key(XF86AudioLowerVolume)",
            "mapping_type": "key_macro"
          },
          {
            "input_combination": [
              {
                "type": 1,
                "code": 276,
                "origin_hash": "75dcd3ec37be26ef3b32ef821e4c5fc7"
              }
            ],
            "target_uinput": "keyboard",
            "output_symbol": "key(XF86AudioRaiseVolume)",
            "mapping_type": "key_macro"
          }
      ]
    '';
    };
    # DeathAdder V3 Pro - apex-legends
    home.file.".config/input-remapper-2/presets/Razer Razer DeathAdder V3 Pro/apex-legends.json" = {
      text = ''
        [
          {
            "input_combination": [
              {
                "type": 1,
                "code": 275,
                "origin_hash": "75dcd3ec37be26ef3b32ef821e4c5fc7"
              }
            ],
            "target_uinput": "keyboard",
            "output_symbol": "key(q)",
            "mapping_type": "key_macro"
          },
          {
            "input_combination": [
              {
                "type": 1,
                "code": 276,
                "origin_hash": "75dcd3ec37be26ef3b32ef821e4c5fc7"
              }
            ],
            "target_uinput": "keyboard",
            "output_symbol": "key(g)",
            "mapping_type": "key_macro"
          }
        ]
      '';
    };

    # my scripts relevant to input-remapper
    home.sessionPath = ["$HOME/.local/scripts"];
    # this is a script to be run before the game starts
    # it should be added via launch options  in steam
    # "/home/ben/.local/scripts/game.inputremapper.apexlegends && %command% && /home/ben/.local/scripts/game.inputremapper.defaults"
    home.file.".local/scripts/game.inputRemapper.apexLegends" = {
      executable = true;
      text = ''
        #!/bin/sh
        input-remapper-control --command start --device "Razer Razer DeathAdder V3 Pro" --preset "apex-legends"
      '';
    };
    home.file.".local/scripts/game.inputRemapper.defaults" = {
      executable = true;
      text = ''
        #!/bin/sh
        input-remapper-control --command start --device "Razer Razer DeathAdder V3 Pro" --preset "default"
      '';
    };
  };
}
