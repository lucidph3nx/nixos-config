{
  osConfig,
  pkgs,
  lib,
  ...
}: {
  home.file.".local/scripts/system.blocky.pause" = lib.mkIf osConfig.nixModules.blocky.enable {
    executable = true;
    text =
      /*
      bash
      */
      ''
        #!/bin/sh
          ${pkgs.blocky}/bin/blocky blocky disable --duration 10m --groups default
      '';
  };
}
