{
  config,
  lib,
  ...
}:
with config.theme;
{
  config = lib.mkIf config.nx.desktop.rofi.enable {
    # notion API key
    sops.secrets.notion_shopping_list_key = {
      owner = "ben";
      mode = "0600";
      sopsFile = ./secrets/notion.sops.yaml;
    };
    environment.sessionVariables = {
      NOTION_SHOPPING_LIST_KEY = "$(cat ${config.sops.secrets.notion_shopping_list_key.path})";
    };
    home-manager.users.ben.home = {
      file.".local/scripts/home.shoppinglist.addItem" = {
        executable = true;
        text =
          # python
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
  };
}
