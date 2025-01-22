{
  config,
  lib,
  ...
}: {
  options = {
    homeManagerModules.ssh.server.enable =
      lib.mkEnableOption "enables a client style ssh config intended for remote servers";
  };
  config = lib.mkIf config.homeManagerModules.ssh.server.enable {
    programs.ssh = {
      enable = true;
      # TODO: design a module for servers
      #     # once I convert all my servers over to nixos ;)
    };
  };
}
