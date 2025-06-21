{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.python.enable =
      lib.mkEnableOption "enables python env"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.programs.python.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        (python3.withPackages (python313Packages: [
          python313Packages.requests
        ]))
      ];
    };
  };
}
