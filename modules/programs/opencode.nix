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
      programs.opencode = {
        enable = true;
        settings = {
          theme = "everforest";
          permission = {
            edit = "allow";
            webfetch = "allow";
            bash = {
              "git push" = "ask";
              "git commit" = "ask";
              "git *" = "allow";
              "nh os build" = "allow";
              "*" = "ask";
            };
          };
        };
      };
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/opencode"
        ];
      };
    };
  };
}
