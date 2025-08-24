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
      home.file.".gemini/settings.json" = {
        text = builtins.toJSON ({
          # configuration options can be found here:
          # https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/configuration.md
          selectedAuthType = "oauth-personal";
          contextFileName = "AGENTS.md";
          preferredEditor = "neovim";
          vimMode = true;
          theme = "custom";
          customThemes = with config.theme; {
            custom = {
              name = "custom";
              type = "custom";
              Background = "${bg0}";
              Foreground = "${foreground}";
              LightBlue = "${primary}";
              AccentBlue = "${blue}";
              AccentPurple = "${purple}";
              AccentCyan = "${aqua}";
              AccentGreen = "${green}";
              AccentYellow = "${yellow}";
              AccentRed = "${red}";
              Comment = "${grey1}";
              Gray = "${grey1}";
              DiffAdded = "${green}";
              DiffRemoved = "${red}";
              DiffModified = "${blue}";
              GradientColors = [
                "${red}"
                "${yellow}"
                "${green}"
                "${blue}"
                "${purple}"
              ];
            };
          };
        });
      };
    };
  };
}
