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
            plugin = [
              # a plugin to use Gemini auth for LLM access
              "opencode-gemini-auth@latest"
            ];
          };
        };
        xdg.configFile."opencode/opencode.json".source =
          config.home-manager.users.ben.xdg.configFile."opencode/config.json".source;
        xdg.configFile."opencode/AGENTS.md".text = /* markdown */ ''
          # Global Agent Instructions

          ## Skills
          When working in environments with domain-specific skills available (via the `skill` tool), err on the side of loading them. If a conversation touches a domain that has a skill, load it – even if you think you know the conventions from other context sources.
          Skills exist to prevent context drift and ensure consistency, not just for when you're uncertain. Loading a skill is cheap; missing domain-specific conventions or creating inconsistency is expensive.

          ## Web Fetching

          When the `webfetch` tool fails with a 403 Forbidden error or similar access restrictions, use a subagent with Playwright to fetch the content with a real browser instead.

          ### Usage

          If webfetch returns a 403 error:
          ```
          Error: HTTP 403 Forbidden
          ```

          Do NOT use the playwright_* tools directly in the main conversation, as they generate very large outputs that quickly fill the context window.

          Instead, use the Task tool to launch a subagent that will use Playwright to extract the content and return only the relevant information:
          ```
          Launch a general subagent with a prompt like:
          "Use the Playwright MCP server to navigate to [URL], extract [specific content needed], and return only the extracted information as markdown. Do not include full page snapshots or accessibility trees in your response to me."
          ```

          The subagent will handle all the verbose Playwright interactions in its own context, and only return the clean, extracted content back to you.
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
