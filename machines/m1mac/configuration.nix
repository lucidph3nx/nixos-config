{ pkgs, inputs, ... }:

{
  # imports =
  # [
  #   inputs.home-manager.darwinModules.home-manager
  # ];
  programs.zsh.enable = true;
  environment = {
    shells = [ pkgs.bash pkgs.zsh ];
    loginShell = pkgs.zsh;
    systemPackages = [ pkgs.eza ];
  };
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  fonts.fontDir.enable = true;
  fonts.fonts = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ];})
  ];
  services.nix-daemon.enable = true;
  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
    };
    dock = {
      autohide = true;
      # basically, permanantly hide dock
      autohide-delay = 1000.0;
      orientation = "left";
    };
  };

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users = {
      ben.imports = [
        ./home.nix
      ];
    };
  };
}
