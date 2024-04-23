{ config, lib, pkgs, inputs, ... }:

{
  options = {
    homeManagerModules.neovim.enable =
      lib.mkEnableOption "Set up Neovim";
  };
  imports = [
    # ./autocmd.nix
    # ./keymaps.nix
    # ./options.nix
    # ./plugins
  ];
  config = lib.mkIf config.homeManagerModules.neovim.enable {
    home.sessionVariables.EDITOR = "nvim";
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      package = pkgs.neovim-unwrapped;
      # package = pkgs.neovim-nightly;
      extraLuaConfig = 
        /*
        lua
        */
        ''
          -- test
        '';
      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-autopairs;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              -- ${nvim-autopairs}
              require('nvim-autopairs').setup{}
            '';
        }
      ];
    };
    xdg.configFile."nvim/init.lua".onChange =
    /*
    bash
    */
    ''
      XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
      for server in $XDG_RUNTIME_DIR/nvim.*; do
        nvim --server $server --remote-send '<Esc>:source $MYVIMRC<CR>' &
      done
    '';
  };
}
