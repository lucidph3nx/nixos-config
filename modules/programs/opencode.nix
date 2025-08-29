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
        opencode
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/opencode"
        ];
      };
      home.file.".config/opencode/opencode.jsonc" = {
        text = builtins.toJSON ({
          theme = "everforest";
          permission = {
            edit = "allow";
            "webfetch" = "allow";
            bash = {
              "git push" = "ask";
              "git commit" = "ask";
              "git *" = "allow";
              "nh os build" = "allow";
              "*" = "ask";
            };
          };
        });
      };
    };
  };
}
