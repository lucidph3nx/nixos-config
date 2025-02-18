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
      # not necessary on this machine, steam gets its own drive
      # {
      #   directory = ".local/share/Steam";
      #   method = "symlink";
      # }
    ];
  };

  home.packages = with pkgs; [
    # retro gaming
    mednafen
    pcsx2
  ];

  wayland.windowManager.hyprland.settings.monitor = [
    "DP-3,5120x1440@239.76Hz,0x0,1"
  ];

  home.sessionVariables = {
    MEDNAFEN_HOME = "${config.xdg.configHome}/mednafen";
  };
}
