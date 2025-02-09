{
  config,
  pkgs-stable,
  pkgs-master,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
  };
  home.stateVersion = "24.05"; # Do Not Touch!

  home.persistence."/persist/home/ben" = {
    allowOther = true;
    directories = [
      {
        directory = ".local/share/Steam";
        method = "symlink";
      }
      ".local/share/lutris"
      ".local/share/PrismLauncher"
      ".local/share/vulkan"
      ".local/share/applications" # where steam puts its .desktop files for games
      ".local/share/icons/hicolor" # where steam puts its icons
    ];
  };

  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1,2880x1800@120.00000,0x0,1.5"
  ];

  home.packages = with pkgs; [
    gimp
    pkgs-stable.prismlauncher # open source minecraft launcher
    # cinnamon.nemo
  ];

  home.sessionVariables = {
    PAGER = "less";
  };
}
