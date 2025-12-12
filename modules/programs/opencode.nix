{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.opencode.enable =
      lib.mkEnableOption "enables opencode"
      // {
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
            nodejs_24
          ];
          programs.zsh.shellAliases = {
            # set environment variables for opencode
            opencode = "${envPrefix} opencode";
          };
          programs.neovim.extraLuaConfig = lib.mkAfter
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
              "type *" = "allow";
              "which *" = "allow";
              # git and gh commands
              "gh issue view *" = "allow";
              "gh pr view *" = "allow";
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
          agent = {
            creative = {
              enabled = true;
              temperature = 0.8;
            };
          };
        };
      };
      xdg.configFile."opencode/opencode.json".source =
        config.home-manager.users.ben.xdg.configFile."opencode/config.json".source;
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
