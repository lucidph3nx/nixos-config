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
  config = lib.mkIf config.nx.programs.opencode.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        nodejs_24
      ];
      programs.opencode = {
        enable = true;
        settings = {
          theme = config.theme.opencodename;
          permission = {
            edit = "allow";
            webfetch = "allow";
            bash = {
              "git *" = "allow";
              "git diff *" = "allow";
              "git commit *" = "allow";
              "git push" = "ask";
              "git push *" = "ask";
              "grep *" = "allow";
              "rg *" = "allow";
              "find *" = "allow";
              "tree *" = "allow";
              "sed *" = "allow";
              "ls *" = "allow";
              "mkdir *" = "allow";
              "npm *" = "allow";
              "rm *" = "allow";
              "nixfmt *" = "allow";
              "nix build *" = "allow";
              "nix flake check *" = "allow";
              "*" = "ask";
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
