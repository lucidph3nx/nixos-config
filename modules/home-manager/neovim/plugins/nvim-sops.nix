{pkgs, ...}:
# merged but not yet showing in unstable
# https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=nvim-sops
let
  nvim-sops = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-sops";
    src = pkgs.fetchFromGitHub {
      owner = "lucidph3nx";
      repo = "nvim-sops";
      rev = "cb2209562d00ef8c6c88bdec836d9edb8fbb96ef";
      hash = "sha256-kppkZtdDQzsqOL+iAclc8Ziij8ZaC9r1m6SNKEu3fTs=";
    };
  };
in {
  programs.neovim.plugins = [
    {
      # plugin = pkgs.vimPlugins.nvim-sops;
      plugin = nvim-sops;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('nvim_sops').setup {
            enabled = true,
            debug = true,
          }
          vim.keymap.set('n', '<leader>ef',
            vim.cmd.SopsEncrypt, { desc = '[E]ncrypt [F]ile' })
          vim.keymap.set('n', '<leader>df',
            vim.cmd.SopsDecrypt, { desc = '[D]ecrypt [F]ile' })
        '';
    }
  ];
}
