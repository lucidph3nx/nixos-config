{ config, nixpkgs-unstable, lib, pkgs, inputs, ... }:

{
  options = {
    homeManagerModules.neovim.enable =
      lib.mkEnableOption "Set up Neovim";
  };
  imports = [
    ./autocmd.nix
    ./keymaps.nix
    ./options.nix
    # ./plugins
  ];
  config = lib.mkIf config.homeManagerModules.neovim.enable {
    home.sessionVariables.EDITOR = "nvim";
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      package = nixpkgs-unstable.neovim-unwrapped;
      # package = pkgs.neovim-nightly;
      plugins = with pkgs.vimPlugins; [
        vim-table-mode
        editorconfig-nvim
        vim-surround
        {
          plugin = nvim-autopairs;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require('nvim-autopairs').setup{}
            '';
        }
      ];
    };
  };
}
