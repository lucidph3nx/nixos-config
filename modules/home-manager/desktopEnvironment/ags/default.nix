{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [inputs.ags.homeManagerModules.default];

  home.packages = [pkgs.networkmanagerapplet];

  programs.ags = {
    enable = true;

    # additional packages to add to gjs's runtime
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk
      accountsservice
      inputs.ags.packages.${pkgs.system}.hyprland
    ];
  };

  # home.file = {
  #   ".config/ags/config.js".source = ./config/config.js;
  # };
  # just persist for now while i work on it
  home.persistence."/persist/home/ben" = {
    directories = [
      ".config/ags"
    ];
  };
}
