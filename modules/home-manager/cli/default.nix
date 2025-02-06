{lib, ...}: {
  imports = [
    ./fastfetch.nix
    ./git.nix
    ./homeAutomation.nix
    ./kubetools.nix
    ./tmux.nix
    ./tmuxSessioniser.nix
    ./zsh.nix
  ];

  homeManagerModules = {
    git.enable = lib.mkDefault true;
    homeAutomation.enable = lib.mkDefault false;
    kubetools.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
    tmuxSessioniser.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
  };
}
