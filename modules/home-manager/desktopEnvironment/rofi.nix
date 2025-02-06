{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
with config.theme; let
  terminal = "${pkgs.kitty}/bin/kitty";
in {
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
        border-color: ${bg_dim};
        border: 1;
        width: 1042px;
      }
      mainbox {
        margin: 5px;
      }
      inputbar {
        border-color: ${green};
        border: 2px;
        children: [prompt, entry];
      }
      prompt {
        color: ${foreground};
        padding: 10px;
      }
      entry {
        padding: 10px;
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
    home.file.".local/scripts/application.nvim.sessionLauncher" = 
      lib.mkIf osConfig.nx.programs.tmuxSessioniser.enable {
      executable = true;
      text = let
        nvimSessionLauncherStyle = ''inputbar { children: [entry]; border-color: ${blue};} entry { placeholder: "Select Project"; } element-icon { enabled: false; }'';
      in ''
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
    home.file.".local/scripts/home.shoppinglist.addItem" = {
      executable = true;
      text =
        /*
        python
        */
        ''
          #!/usr/bin/env python3
          import os
          import json
          import subprocess
          import requests

          NOTION_KEY = os.getenv("NOTION_SHOPPING_LIST_KEY")
          NOTION_URL = (
              "https://api.notion.com/v1/blocks/92d98ac3dc86460285a399c0b1176fc5/children"
          )
          ROFI_STYLE = 'listview { enabled: false;} inputbar { children: [entry]; border-color: ${purple};} entry { placeholder: "Add Item to Shopping List"; }'


          def add_item(item):
              headers = {
                  "Authorization": f"Bearer {NOTION_KEY}",
                  "Content-Type": "application/json",
                  "Notion-Version": "2022-02-22",
              }
              data = {
                  "children": [
                      {
                          "object": "block",
                          "type": "to_do",
                          "to_do": {
                              "rich_text": [{"type": "text", "text": {"content": item}}],
                              "checked": False,
                          },
                      }
                  ]
              }
              response = requests.patch(NOTION_URL, headers=headers, json=data)
              status = (
                  "Item added successfully."
                  if response.status_code == 200
                  else f"Failed. HTTP: {response.status_code}"
              )
              subprocess.run(["notify-send", "-i", "notes", "-t", "2000", "-e", "Notion", status])


          selected_item = subprocess.run(
              ["rofi", "-dmenu", "-i", "-theme-str", ROFI_STYLE], capture_output=True, text=True
          ).stdout.strip()
          if selected_item:
              add_item(selected_item)
        '';
    };
  };
}
