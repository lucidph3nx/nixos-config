{...}: {
  imports = [
    ./batteryNotifier.nix
    ./blocky.nix
    ./greetd.nix
    ./mpd.nix
    ./pipewire.nix
    ./polkit.nix
    ./powerProfilesDaemon.nix
    ./printer.nix
    ./syncthing
    ./udiskie.nix
  ];
  config = {
    # default service configuration, things that don't need their own module

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
  };
}
