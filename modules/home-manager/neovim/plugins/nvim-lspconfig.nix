{pkgs, ...}: {
  home.packages = with pkgs; [
    helm-ls
    lua-language-server
    nil
    terraform-ls
    typescript-language-server
    yaml-language-server
  ];
  programs.neovim.plugins = [
    # LSP and completions for injected langs
    pkgs.vimPlugins.otter-nvim
    pkgs.vimPlugins.cmp-nvim-lsp
    pkgs.vimPlugins.vim-helm
    # LSP
    {
      plugin = pkgs.vimPlugins.nvim-lspconfig;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          local lspconfig = require("lspconfig")
          function add_lsp(server, options)
          	if not options["cmd"] then
          		options["cmd"] = server["document_config"]["default_config"]["cmd"]
          	end
          	if not options["capabilities"] then
          		options["capabilities"] = require("cmp_nvim_lsp").default_capabilities()
          	end

          	if vim.fn.executable(options["cmd"][1]) == 1 then
          		server.setup(options)
          	end
          end

          add_lsp(lspconfig.clojure_lsp, {})
          add_lsp(lspconfig.cssls, {})
          add_lsp(lspconfig.dockerls, {})
          add_lsp(lspconfig.eslint, {})
          add_lsp(lspconfig.gopls, {})
          add_lsp(lspconfig.graphql, {})
          add_lsp(lspconfig.helm_ls, {})
          add_lsp(lspconfig.html, {})
          add_lsp(lspconfig.jsonls, {})
          add_lsp(lspconfig.lua_ls, {})
          add_lsp(lspconfig.nil_ls, {
          	settings = { ["nil"] = {
          		formatting = { command = { "alejandra" } },
          	} },
          })
          add_lsp(lspconfig.pylsp, {})
          add_lsp(lspconfig.rust_analyzer, {})
          add_lsp(lspconfig.sqlls, {})
          add_lsp(lspconfig.terraformls, {})
          add_lsp(lspconfig.ts_ls, {})
          add_lsp(lspconfig.yamlls, {
          	settings = { ["yamlls"] = {
          		keyOrdering = false,
          	} },
          })
          -- keymaps
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "[R]e[n]ame" })
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "[C]ode [A]ction" })

          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "[G]oto [D]efinition" })
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "[G]oto [D]eclaration" })
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "[G]oto [I]mplementation" })
          vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "[G]oto [R]eferences" })
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "[K]ind (Hover Documentation)" })

          vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "Type [D]efinition" })
          vim.keymap.set(
          	"n",
          	"<leader>ds",
          	require("telescope.builtin").lsp_document_symbols,
          	{ buffer = bufnr, desc = "[D]ocument [S]ymbols" }
          )
          vim.keymap.set(
          	"n",
          	"<leader>ws",
          	require("telescope.builtin").lsp_workspace_symbols,
          	{ buffer = bufnr, desc = "[W]orkspace [S]ymbols" }
          )
          -- format
          -- vim.keymap.set('n', '<leader>f',
          --   vim.lsp.buf.formatting, { buffer = bufnr, desc = '[F]ormat'})
        '';
    }
  ];
}
