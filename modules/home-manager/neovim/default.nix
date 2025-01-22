{
  config,
  lib,
  ...
}: {
  options = {
    homeManagerModules.neovim.enable =
      lib.mkEnableOption "Set up Neovim";
  };
  imports = [
    ./abbreviations.nix
    ./autocmd.nix
    ./functions.nix
    ./keymaps.nix
    ./options.nix
    ./plugins
  ];
  config = lib.mkIf config.homeManagerModules.neovim.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
    home.persistence."/persist/home/ben" = {
      directories = [
        ".config/nvim/spell"
      ];
    };
    xdg.mimeApps.defaultApplications = lib.mkIf config.programs.neovim.enable {
      "text/plain" = "nvim.desktop";
      "text/markdown" = "nvim.desktop";
    };
  };
}
