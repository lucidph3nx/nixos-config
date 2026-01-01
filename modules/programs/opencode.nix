{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    nx.programs.opencode.enable = lib.mkEnableOption "enables opencode" // {
      default = true;
    };
  };
  config = lib.mkIf config.nx.programs.opencode.enable (
    let
      # Define opencode environment variables in one place
      opencodeEnvVars = {
        KUBECONFIG = "$HOME/.config/kube/agents-config";
      };
      # Build shell command prefix from env vars
      envPrefix = lib.concatStringsSep " " (
        lib.mapAttrsToList (name: value: "${name}=${value}") opencodeEnvVars
      );
    in
    {
      home-manager.users.ben = {
        home.packages = with pkgs; [
          # need npx on path for memory mcp
          nodejs_24
        ];
        programs.zsh.shellAliases = {
          # set environment variables for opencode
          opencode = "${envPrefix} opencode";
        };
        programs.neovim.extraLuaConfig =
          lib.mkAfter
            # lua
            ''
              -- open current project in new kitty window with opencode
              vim.keymap.set(
                "n",
                "<leader>oa",
                ":!kitty -d $(pwd) env ${envPrefix} opencode . &<CR><CR>",
                { silent = true, desc = "[O]pen project with [A]I agent" }
              )
            '';
        programs.opencode = {
          enable = true;
          settings = {
            theme = config.theme.opencodename;
            mcp = {
              playwright = {
                type = "local";
                command = [
                  "${pkgs.playwright-mcp}/bin/mcp-server-playwright"
                  "--executable-path"
                  "${pkgs.chromium}/bin/chromium"
                  "--headless"
                ];
                enabled = true;
              };
            };
            permission = {
              edit = "allow";
              webfetch = "allow";
              bash = {
                # default for any command not listed is ask
                "*" = "ask";
                # we have made sure above that opencode runs with a readonly kubeconfig
                "flux *" = "allow";
                "helm *" = "allow";
                "kubectl *" = "allow";
                # file reading/viewing
                "cat *" = "allow";
                "head *" = "allow";
                "less *" = "allow";
                "more *" = "allow";
                "tail *" = "allow";
                # file/directory listing
                "file *" = "allow";
                "find *" = "allow";
                "ls *" = "allow";
                "tree *" = "allow";
                # text processing/searching
                "awk *" = "allow";
                "comm *" = "allow";
                "cut *" = "allow";
                "diff *" = "allow";
                "grep *" = "allow";
                "rg *" = "allow";
                "sed *" = "allow";
                "sort *" = "allow";
                "uniq *" = "allow";
                "wc *" = "allow";
                # system information (read-only)
                "date *" = "allow";
                "env *" = "allow";
                "hostname *" = "allow";
                "id *" = "allow";
                "printenv *" = "allow";
                "pwd *" = "allow";
                "uname *" = "allow";
                "whoami *" = "allow";
                # json/yaml processing
                "jq *" = "allow";
                "yq *" = "allow";
                # utilities
                "basename *" = "allow";
                "command *" = "allow";
                "dirname *" = "allow";
                "echo *" = "allow";
                "printf *" = "allow";
                "sleep *" = "allow";
                "type *" = "allow";
                "which *" = "allow";
                # git and gh commands
                "gh issue view *" = "allow";
                "gh pr view *" = "allow";
                "gh pr list *" = "allow";
                "git *" = "allow";
                "git commit *" = "allow";
                "git diff *" = "allow";
                "git push *" = "ask";
                "git push" = "ask";
                # file operations that modify
                "mkdir *" = "allow";
                "rm *" = "allow";
                "mv *" = "allow";
                # nix commands
                "nh os build" = "allow";
                "nh os switch" = "ask";
                "nix build *" = "allow";
                "nix flake check *" = "allow";
                "nixfmt *" = "allow";
                # other dev tools
                "npm *" = "allow";
              };
            };
          };
        };
        xdg.configFile."opencode/opencode.json".source =
          config.home-manager.users.ben.xdg.configFile."opencode/config.json".source;
        xdg.configFile."opencode/AGENTS.md".text = /* markdown */ ''
          # Global Agent Instructions

          ## Web Fetching

          When the `webfetch` tool fails with a 403 Forbidden error or similar access restrictions, use the Playwright MCP server as an alternative to fetch web content with a real browser.

          ### Usage

          If webfetch returns a 403 error:
          ```
          Error: HTTP 403 Forbidden
          ```

          Try using the Playwright MCP server instead:
          ```
          Use the playwright_navigate tool to load the page with a real browser, then use playwright_screenshot or playwright_evaluate to extract the content.
          ```

          Playwright can bypass many simple bot detection mechanisms that block basic HTTP requests.
        '';
        home.persistence."/persist/home/ben" = {
          directories = [
            ".config/opencode"
            ".local/share/opencode"
            ".local/state/opencode"
          ];
        };
      };
    }
  );
}
