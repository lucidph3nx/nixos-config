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
  config = lib.mkIf config.nx.programs.opencode.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        nodejs_24
      ];
      programs.zsh.shellAliases = {
        # set KUBECONFIG to agents config for opencode
        opencode = "KUBECONFIG=$HOME/.config/kube/agents-config opencode";
      };
      programs.opencode = {
        enable = true;
        settings = {
          theme = config.theme.opencodename;
          permission = {
            edit = "allow";
            webfetch = "allow";
            bash = {
              "*" = "ask";
              "find *" = "allow";
              "gh issue view *" = "allow";
              "gh pr view *" = "allow";
              "git *" = "allow";
              "git commit *" = "allow";
              "git diff *" = "allow";
              "git push *" = "ask";
              "git push" = "ask";
              "grep *" = "allow";
              "helm dependency update" = "allow";
              "helm template *" = "allow";
              "ls *" = "allow";
              "mkdir *" = "allow";
              "nh os build" = "allow";
              "nh os switch" = "ask";
              "nix build *" = "allow";
              "nix flake check *" = "allow";
              "nixfmt *" = "allow";
              "npm *" = "allow";
              "rg *" = "allow";
              "rm *" = "allow";
              "sed *" = "allow";
              "tree *" = "allow";
              "wc *" = "allow";
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
  };
}
