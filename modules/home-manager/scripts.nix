{ config, pkgs, ... }:

# a temporary solution
# scripts should be grouped into domains
{
  home.sessionPath = ["~/.local/scripts"];
  home.file = {
    ".local/scripts/" = {
      source = ./scripts;
      recursive = true;
    };
  };
}
