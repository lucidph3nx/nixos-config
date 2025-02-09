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
  config = {
    # increase network buffer size
    boot.kernel.sysctl."net.core.rmem_max" = 2500000;
    # XDG env vars
    environment.sessionVariables = {
      # General XDG variables
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_CACHE_HOME = "$HOME/.cache";
    };
  };
}
