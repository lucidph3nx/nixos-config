{ config, pkgs, nixpkgs-unstable, ... }:

{
  programs.mise = {
  	enable = true;
    package = nixpkgs-unstable.mise;
    globalConfig = {
      tools = { node = "lts";};# terragrunt = "0.24.4"; terraform = "0.12.31";};
    };
  };
}
