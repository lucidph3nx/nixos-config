{
  pkgs,
  ...
}: {
  home-manager.users.ben.programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (treesitter-plugins:
        with treesitter-plugins; [
          bash
          clojure
          cmake
          css
          dockerfile
          gitcommit
          gitignore
          graphql
          hcl
          helm
          html
          javascript
          jq
          json
          json5
          jsonc
          latex
          mermaid
          commonlisp
          lua
          markdown
          nginx
          nix
          python
          rust
          scala
          ssh_config
          sql
          tmux
          toml
          typescript
          vim
          yaml
        ]);
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("nvim-treesitter.configs").setup({
          	highlight = {
          		enable = true,
          		additional_vim_regex_highlighting = { "markdown" },
          	},
          	indent = { enable = true },
          	incremental_selection = {
          		enable = true,
          		keymaps = {
          			init_selection = "<CR>",
          			scope_incremental = "<CR>",
          			node_incremental = "<TAB>",
          			node_decremental = "<S-TAB>",
          		},
          	},
          	textobjects = {
          		select = {
          			enable = true,
          			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          			keymaps = {
          				-- You can use the capture groups defined in textobjects.scm
          				["aa"] = "@parameter.outer",
          				["ia"] = "@parameter.inner",
          				["af"] = "@function.outer",
          				["if"] = "@function.inner",
          				["ac"] = "@class.outer",
          				["ic"] = "@class.inner",
          			},
          		},
          		move = {
          			enable = true,
          			set_jumps = true, -- whether to set jumps in the jumplist
          			goto_next_start = {
          				["]m"] = "@function.outer",
          				["]]"] = "@class.outer",
          			},
          			goto_next_end = {
          				["]M"] = "@function.outer",
          				["]["] = "@class.outer",
          			},
          			goto_previous_start = {
          				["[m"] = "@function.outer",
          				["[["] = "@class.outer",
          			},
          			goto_previous_end = {
          				["[M"] = "@function.outer",
          				["[]"] = "@class.outer",
          			},
          		},
          		swap = {
          			enable = true,
          			swap_next = {
          				["<leader>a"] = "@parameter.inner",
          			},
          			swap_previous = {
          				["<leader>A"] = "@parameter.inner",
          			},
          		},
          	},
          })
        '';
    }
  ];
}
