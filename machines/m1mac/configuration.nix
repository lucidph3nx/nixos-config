{ pkgs, ... }

{
  imports = 
  [
    inputs.home-manager.darwinModules.home-manager
  ];
  programs.zsh.enable = true;
  environment = {
    shells = [ pkgs.bash, pkgs.zsh ];
    loginShell = pkgs.zsh;
  };
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  systemPackages = [ pkgs.eza ];
  fonts.fontDir.enable = true;
  fonts.fonts = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ];})
  ];
  service.nix-daemon.enable = true;
  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
    };
    dock = {
      autohide = true;
      # basically, permanantly hide dock
      autohide-delay = 1000;
      orientation = "left";
    };
  };

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "ben" = import ./home.nix;
    }
  }
}
