{
  config,
  lib,
  ...
}: {
  options = {
    nx.programs.nh.enable =
      lib.mkEnableOption "enables nix helper tool"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.programs.nh.enable {
    programs.nh = {
      enable = true;
      flake = "/home/ben/code/nixos-config";
    };
  };
}
