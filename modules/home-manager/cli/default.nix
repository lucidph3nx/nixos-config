{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./k9s.nix
    ./kubetools.nix
    ./tmux.nix
  ];

  home-manager-modules = {
    k9s.enable = lib.mkDefault true;
    kubetools.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
  };

}
