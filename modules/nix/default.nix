{lib, ...}: {
  options = {
    nx.externalAudio.enable = lib.mkEnableOption {
      default = false;
      description = "machine is using external audio control, disable things like volume controls";
    };
    nx.deviceLocation = lib.mkOption {
      default = "none";
      description = "physical location of the machine, for showing local variables like temp humidity";
      type = lib.types.str;
    };
    nx.isLaptop = lib.mkEnableOption {
      default = false;
      description = "machine is a laptop, enable things like battery monitoring";
    };
  };
  config = {
    # increase network buffer size
    boot.kernel.sysctl."net.core.rmem_max" = 2500000;

    virtualisation.podman.enable = true;
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
