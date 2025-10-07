{ pkgs, ... }:
{
  home-manager.users.ben = {
    programs.neovim.plugins = [
      {
        plugin = pkgs.vimPlugins.copilot-lua;
        type = "lua";
        config =
          # lua
          ''
            require("copilot").setup({
            copilot_node_command = "${pkgs.nodejs_24}/bin/node";
            	panel = {
            		enabled = false,
            	},
            	suggestion = {
            		enabled = true,
            		auto_trigger = true,
            		debounce = 75,
            		keymap = {
            			accept = "<C-L>",
            			next = "<C-J>",
            			prev = "<C-K",
            		},
            	},
            	filetypes = {
            		markdown = true,
            		yaml = true,
            		help = false,
            		gitcommit = false,
            		gitrebase = false,
            		hgcommit = false,
            		svn = false,
            		cvs = false,
            		["."] = true,
            		rust = false, -- while learning rust, no copilot
            	},
            })
          '';
      }
    ];
    home.persistence."/persist/home/ben" = {
      directories = [
        ".config/github-copilot"
      ];
    };
  };
}
