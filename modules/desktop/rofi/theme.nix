{
  config,
  lib,
  ...
}:
with config.theme; {
  config = lib.mkIf config.nx.desktop.rofi.enable {
    home-manager.users.ben.home.file.".config/rofi/theme.rasi".text = ''
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
  };
}
