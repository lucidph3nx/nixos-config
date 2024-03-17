{ config, pkgs, ... }:

# a temporary solution
# scripts should be grouped into domains
{
  home.file = {
    ".local/scripts/" = {
      source = ./scripts;
      recursive = true;
    };
  };
}
