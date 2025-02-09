{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
  };
  home.stateVersion = "24.05"; # Do Not Touch!


  home.packages = with pkgs; [
    gimp # temp for troubleshooting
    # cinnamon.nemo
  ];

  home.sessionVariables = {
    PAGER = "less";
  };
}
