{lib, ...}: {
  imports = [
    ./git.nix
    ./homeAutomation.nix
    ./tmux.nix
    ./tmuxSessioniser.nix
    ./zsh.nix
  ];

  homeManagerModules = {
    git.enable = lib.mkDefault true;
    homeAutomation.enable = lib.mkDefault false;
    tmux.enable = lib.mkDefault true;
    tmuxSessioniser.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
  };
}
