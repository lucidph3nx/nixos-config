{pkgs, ...}:
{
  programs.neovim.plugins = [
    pkgs.vimPlugins.tabular
    {
      plugin = pkgs.vimPlugins.vim-markdown;
      type = "lua";
      config = 
        /*
        lua
        */
        ''
          vim.g.vim_markdown_folding_disabled = 1
          vim.g.vim_markdown_frontmatter = 0
          vim.g.vim_markdown_auto_insert_bullets = 0
          vim.opt.conceallevel = 2
        '';
    }
  ];
}
