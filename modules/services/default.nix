{...}: {
  imports = [
    ./blocky.nix
    ./dbus.nix
    ./greetd.nix
    ./mouseBatteryMonitor.nix
    ./mpd.nix
    ./pipewire.nix
    ./polkit.nix
    ./printer.nix
    ./syncthing
    ./udiskie.nix
  ];
  config = {
    # default service configuration, things that don't need their own module

    # power management
    services.power-profiles-daemon.enable = true;

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
  };
}
