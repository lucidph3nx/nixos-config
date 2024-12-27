{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    inputs.ags.homeManagerModules.default
    ./style.scss.nix
  ];
  options = {
    homeManagerModules.ags.enable =
      lib.mkEnableOption "Enable AGS"
      // {
        default = false;
      };
  };
  config = lib.mkIf config.homeManagerModules.ags.enable {
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
    home.file = {
      ".config/ags/app.ts".source = ./config/app.ts;
      ".config/ags/tsconfig.json".source = ./config/tsconfig.json;
      ".config/ags/widget/Overview.tsx".source = ./config/widget/Overview.tsx;
      ".config/ags/lib/DynamicProperty.ts".source = ./config/lib/DynamicProperty.ts;
      ".config/ags/lib/mpd.ts".source = ./config/lib/mpd.ts;
    };
    # just persist for now while i work on it
    home.persistence."/persist/home/ben" = {
      directories = [
        ".config/ags"
      ];
    };
  };
}
