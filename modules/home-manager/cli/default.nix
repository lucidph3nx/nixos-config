{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./homeAutomation.nix
    ./k9s.nix
    ./kubetools.nix
    ./tmux.nix
    ./tmuxSessioniser.nix
  ];

  home-manager-modules = {
    homeAutomation.enable = lib.mkDefault false;
    k9s.enable = lib.mkDefault true;
    kubetools.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
    tmuxSessioniser.enable = lib.mkDefault true;
  };

}
