{ config, lib, pkgs, inputs, ... }:

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
      package = pkgs.neovim-unwrapped;
      # package = pkgs.neovim-nightly;
      plugins = with pkgs.vimPlugins; [
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
