{...}: {
  imports = [
    # ./home-manager
    ./nix
    ./colourScheme
    ./services
    ./programs
  ];
  config = {
    # Let Home Manager install and manage itself.
    home-manager.users.ben.programs.home-manager.enable = true;
  };
}
