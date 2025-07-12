{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.gemini-cli.enable =
      lib.mkEnableOption "enables gemini-cli"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.programs.gemini-cli.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        gemini-cli
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".gemini"
        ];
      };
    };
  };
}
