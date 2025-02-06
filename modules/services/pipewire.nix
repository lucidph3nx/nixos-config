{
  config,
  lib,
  ...
}: {
  options = {
    nx.pipewire.enable =
      lib.mkEnableOption "Enable pipewire for audio"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.pipewire.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      audio.enable = true;
      wireplumber.enable = true;
    };
  };
}
