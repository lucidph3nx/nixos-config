{...}: {
  imports = [
    ./hardware-boot-switch.nix
    ./impermanence.nix
    ./localisation.nix
    ./nfs-mounts.nix
    ./nix-options.nix
    ./users.nix
    ./sops.nix
  ];
}
