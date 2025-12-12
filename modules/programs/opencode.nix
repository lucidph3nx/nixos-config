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
              # basic file ops
              "find *" = "allow";
              "grep *" = "allow";
              "ls *" = "allow";
              "mkdir *" = "allow";
              "rg *" = "allow";
              "rm *" = "allow";
              "sed *" = "allow";
              "tree *" = "allow";
              "wc *" = "allow";
              # git and gh commands
              "gh issue view *" = "allow";
              "gh pr view *" = "allow";
              "git *" = "allow";
              "git commit *" = "allow";
              "git diff *" = "allow";
              "git push *" = "ask";
              "git push" = "ask";
              # nix commands
              "nh os build" = "allow";
              "nh os switch" = "ask";
              "nix build *" = "allow";
              "nix flake check *" = "allow";
              "nixfmt *" = "allow";
              # other
              "npm *" = "allow";
              "yq eval *" = "allow";
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
