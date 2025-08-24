{
  config,
  lib,
  ...
}:
{
  options = {
    nx.programs.podman.enable = lib.mkEnableOption "enables podman" // {
      default = true;
    };
  };
  config = lib.mkIf config.nx.programs.podman.enable {
    virtualisation.podman.enable = true;
  };
}
