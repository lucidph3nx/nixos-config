{...}: {
  imports = [
    ./hardware-boot-switch.nix
    ./impermanence.nix
    ./localisation.nix
    ./networking.nix
    ./nfs-mounts.nix
    ./nix-options.nix
    ./sops.nix
    ./users.nix
  ];
  config = {
    # XDG env vars
    environment.sessionVariables = {
      # General XDG variables
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
      # due to a bug with libgit2, issues occur when using a mounted cache
      # Its simpler to just use the already persisted cache folder rather than mounting it
      XDG_CACHE_HOME = "/persist/home/ben/.cache";
    };
  };
}
