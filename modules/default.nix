{...}: {
  imports = [
    ./colourScheme
    ./desktop
    ./nix
    ./programs
    ./services
    ./system
  ];
  config = {
    # Let Home Manager install and manage itself.
    home-manager.users.ben.programs.home-manager.enable = true;
  };
}
