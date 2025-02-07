{
  lib,
  # config,
  ...
}: {
  imports = [
    ./desktopEnvironment
  ];
  homeManagerModules = {
    desktopEnvironment.enable = lib.mkDefault true;
  };
}
