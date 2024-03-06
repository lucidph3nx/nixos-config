{ config, pkgs, nixpkgs-unstable, ... }:

# Not yet in the stable home-manager
{
  # programs.mise = {
  # 	enable = true;
  #   package = nixpkgs-unstable.mise;
  #   globalConfig = {
  #     tools = { node = "lts";};# terragrunt = "0.24.4"; terraform = "0.12.31";};
  #   };
  # };
  # doing this instead
  home.packages = [
    nixpkgs-unstable.mise
  ];
  home.file.".config/mise/config.toml".text = ''
  [tools]
  node = ['lts']
  '';
}

