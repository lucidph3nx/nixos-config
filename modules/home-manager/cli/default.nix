{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./asdf.nix
    ./bitwardencli.nix
    ./git.nix
    ./homeAutomation.nix
    ./k9s.nix
    ./kubetools.nix
    ./lf.nix
    ./ncmpcpp.nix
    ./tmux.nix
    ./tmuxSessioniser.nix
    ./zsh.nix
  ];

  homeManagerModules = {
    asdf.enable = lib.mkDefault false;
    bitwardencli.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    homeAutomation.enable = lib.mkDefault false;
    k9s.enable = lib.mkDefault true;
    kubetools.enable = lib.mkDefault true;
    lf.enable = lib.mkDefault true;
    ncmpcpp.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
    tmuxSessioniser.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
  };
}
