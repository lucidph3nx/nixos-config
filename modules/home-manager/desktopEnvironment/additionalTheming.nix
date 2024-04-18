{ config, pkgs, lib, nixpkgs-unstable, ... }:

{
  config = lib.mkIf pkgs.stdenv.isLinux {
    # set up the cusors and icon themes the way I like it
    home.pointerCursor = {
      gtk.enable = true;
      name = "breeze_cursors";
      # this is the cursor I like, from plasma 6
      package = nixpkgs-unstable.kdePackages.breeze;
      size = 24;
    };
    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.gnome-themes-extra;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "breeze_cursors";
      # this is the cursor I like, from plasma 6
        package = nixpkgs-unstable.kdePackages.breeze;
      };
      gtk3 = {
        extraConfig.gtk-application-prefer-dark-theme = true;
      };
    };
    qt = {
      enable = true;
      platformTheme = "gnome";
      style.name = "adwaita-dark";
    };
  };
}
