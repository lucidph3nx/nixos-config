{
  config,
  pkgs,
  lib,
  ...
}:
with config.theme; {
  imports = [
    # rofi launcher scripts
    ./addToShoppingList.nix
    ./applicationLauncher.nix
    ./emojiPicker.nix
    ./nvimSessionLauncher.nix
    ./rofiCalculator.nix
    ./scriptLauncher.nix
    # rofi themeing (theme.rasi)
    ./theme.nix
  ];
  options = {
    nx.desktop.rofi.enable =
      lib.mkEnableOption "enables rofi"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.desktop.rofi.enable {
    home-manager.users.ben = {
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

      # my scripts relevant to rofi
      home.sessionPath = ["$HOME/.local/scripts"];
    };
  };
}
