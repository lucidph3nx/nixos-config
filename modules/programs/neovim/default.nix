{
  config,
  lib,
  ...
}: {
  options = {
    nx.programs.neovim.enable =
      lib.mkEnableOption "Set up Neovim"
      // {
        default = true;
      };
  };
  imports = [
    ./abbreviations.nix
    ./autocmd.nix
    ./keymaps.nix
    ./options.nix
    ./plugins
  ];
  config = lib.mkIf config.nx.programs.neovim.enable {
    home-manager.users.ben = {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
      };
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/nvim/spell"
          ".local/share/nvim"
          ".local/state/nvim"
        ];
      };
      xdg.mimeApps.defaultApplications = lib.mkIf config.programs.neovim.enable {
        "text/plain" = "nvim.desktop";
        "text/markdown" = "nvim.desktop";
      };
    };
  };
}
