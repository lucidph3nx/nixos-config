{pkgs, ...}: {
  home-manager.users.ben.programs.neovim.extraLuaPackages = ps: [ps.magick];
  home-manager.users.ben.programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.image-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("image").setup({
          	backend = "kitty",
          	integrations = {
          		markdown = {
          			enabled = true,
          			clear_in_insert_mode = false,
          			download_remote_images = true,
          			only_render_image_at_cursor = false,
          			filetypes = {
          				"markdown",
          				"vimwiki",
          			},
          		},
          		kitty_method = "normal",
          	},
          })
        '';
    }
  ];
}
