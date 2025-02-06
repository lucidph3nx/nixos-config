{lib, ...}: {
  imports = [
    ./homeAutomation.nix
    ./tmux.nix
    ./tmuxSessioniser.nix
    ./zsh.nix
  ];

  homeManagerModules = {
    homeAutomation.enable = lib.mkDefault false;
    tmux.enable = lib.mkDefault true;
    tmuxSessioniser.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
  };
}
