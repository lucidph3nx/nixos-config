{ config, pkgs, inputs, lib, ... }: {
  options = {
    homeManagerModules.git-sync.enable =
      lib.mkEnableOption "enables git-sync";
  };
  config = {
    services.git-sync = {
      enable = true;
      repositories = {
        "nixos-config" = {
          url = "ssh://git@github.com:lucidph3nx/nixos-config.git";
          path = "${inputs.home-manager.home}/code/nixos-config-test";
        };
      };
    };
  };
}
