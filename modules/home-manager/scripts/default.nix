{
  config,
  pkgs,
  ...
}:
# a temporary solution
# scripts should be grouped into domains
{
  home.sessionPath = ["$HOME/.local/scripts"];
  home.file = {
    ".local/scripts/" = {
      source = ./.;
      recursive = true;
    };
  };
}
