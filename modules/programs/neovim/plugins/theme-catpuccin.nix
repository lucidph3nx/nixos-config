{
  pkgs,
  lib,
  config,
  ...
}:
let
  theme = config.theme;
in
{
  home-manager.users.ben.programs.neovim.plugins = lib.mkIf (config.theme.name == "catppuccin-latte") [
    {
      plugin = pkgs.vimPlugins.catppuccin-nvim;
      type = "lua";
      config =
        # lua
        ''
          require("catppuccin").setup({
            flavour = "latte",
            transparent_background = true,
          })
          vim.cmd("colorscheme catppuccin")
        '';
    }
  ];
}
