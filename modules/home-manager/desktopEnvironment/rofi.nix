{
  config,
  pkgs,
  lib,
  ...
}:
with config.theme; let
  terminal = "${pkgs.kitty}/bin/kitty";
in {
  imports = [../cli/tmuxSessioniser.nix]; #needed for one of the rofi scripts
  options = {
    homeManagerModules.rofi.enable =
      lib.mkEnableOption "enables rofi";
  };
  config = lib.mkIf config.homeManagerModules.rofi.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      font = "JetBrainsMono Nerd Font Medium";
      plugins = with pkgs; [
        (rofi-calc.override {
          rofi-unwrapped = rofi-wayland-unwrapped;
        })
        rofi-emoji-wayland
      ];
      extraConfig = {
        steal-focus = true;
        show-icons = true;
        icon-theme = "Papirus-Dark";
        application-fallback-icon = "run-build";
        drun-display-format = "{icon} {name}";
        matching = "fuzzy";
        scroll-method = 0;
        disable-history = false;
        display-drun = "";
        display-windows = "Windows:";
        display-run = " ";
        sort = true;
        sorting-method = "fzf";
      };
      theme = "~/.config/rofi/theme.rasi";
    };
    home.file.".config/rofi/theme.rasi".text = ''
      * {
        background-color: transparent;
        text-color: ${foreground};
        font: "JetbrainsMono Nerd Font Medium 16px";
      }
      window {
        location: 0;
        background-color: ${bg0};
        border-color: ${bg3};
        border: 2;
        width: 1042px;
      }
      mainbox {
        margin: 15px;
      }
      inputbar {
        border-color: ${green};
        border: 2px;
        children: [prompt, entry];
      }
      prompt {
        color: ${foreground};
        padding: 10px;
        padding-top: 5px;
      }
      entry {
        padding: 10px;
        padding-top: 5px;
        placeholder-color: ${bg5};
      }
      listview {
        margin: 5px 0px 0px 0px;
        lines: 7;
      }
      element {
        padding: 7px;
      }
      element-text {
        padding: 7px;
      }
      element-icon {
        size: 35px;
      }
      element selected {
        background-color: ${primary};
      }
      element-text selected {
        color: ${bg_visual};
      }
    '';
    home.file.".config/rofi-emoji/custom_emoji_list.txt".source = ./files/rofi-custom-emoji-list;

    # my scripts relevant to rofi
    home.sessionPath = ["$HOME/.local/scripts"];
    home.file.".local/scripts/application.launcher" = {
      source = ./scripts/application.launcher;
    };
    homeManagerModules.tmuxSessioniser.enable = true;
    home.file.".local/scripts/application.nvim.sessionLauncher" = let
      nvimSessionLauncherStyle = ''inputbar { children: [entry]; border-color: ${blue};} entry { placeholder: "Select Project"; } element-icon { enabled: false; }'';
    in {
      executable = true;
      text = ''
        #!/bin/sh
        monitor="$(swaymsg -t get_outputs | jq -c '.[] | select(.focused) | select(.id)' | jq -c '.name')"
        # Get the selection from tmux project getter
        selection=$(~/.local/scripts/cli.tmux.projectGetter | rofi -monitor "$monitor" -dmenu -theme-str '${nvimSessionLauncherStyle}')
        if [ -n "$selection" ]; then
          # Run the tmux sessioniser with the selected session
          xargs -I{} ${terminal} ~/.local/scripts/cli.tmux.projectSessioniser "{}" 2> /dev/null <<<"$selection"
        fi
      '';
    };
    home.file.".local/scripts/application.rofi.calculator" = {
      source = ./scripts/application.rofi.calculator;
    };
    home.file.".local/scripts/application.rofi.emojipicker" = {
      source = ./scripts/application.rofi.emojipicker;
    };
    home.file.".local/scripts/application.scripts.launcher" = {
      source = ./scripts/application.scripts.launcher;
    };
    home.file.".local/scripts/system.rofi.powermenu" = {
      source = ./scripts/system.rofi.powermenu;
    };
  };
}
