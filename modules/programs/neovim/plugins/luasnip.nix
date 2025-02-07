{pkgs, ...}: {
  home-manager.users.ben.programs.neovim.plugins = [
    pkgs.vimPlugins.nvim-snippets
    pkgs.vimPlugins.friendly-snippets
    {
      plugin = pkgs.vimPlugins.cmp_luasnip;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("cmp").setup()
        '';
    }
    {
      plugin = pkgs.vimPlugins.luasnip;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("luasnip").setup({})
          local ls = require("luasnip")
          local s = ls.snippet
          local sn = ls.snippet_node
          local t = ls.text_node
          local d = ls.dynamic_node

          -- my snippets
          ls.add_snippets("markdown", {
          	s("[] ", { t("- [ ] ") }),
          })
          ls.add_snippets("markdown", {
          	s(
          		"wikidate",
          		d(1, function(args, parent)
          			local env = parent.snippet.env
          			return sn(
          				nil,
          				t({ "[[" .. env.CURRENT_YEAR .. "-" .. env.CURRENT_MONTH .. "-" .. env.CURRENT_DATE .. "]]" })
          			)
          		end, {})
          	),
          })
        '';
    }
  ];
}
