{...}: {
  imports = [
    ./colourScheme
    ./desktop
    ./impermanence.nix
    ./nix
    ./programs
    ./services
  ];
  config = {
    # Let Home Manager install and manage itself.
    home-manager.users.ben.programs.home-manager.enable = true;
  };
}
