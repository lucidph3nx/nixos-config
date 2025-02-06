{...}: {
  imports = [
    ./blocky.nix
    ./pipewire.nix
    ./polkit.nix
    ./printer.nix
    ./syncthing.nix
    ./udiskie.nix
    ./greetd.nix
  ];
  config = {
    # default service configuration, things that don't need their own module

    # power management
    services.power-profiles-daemon.enable = true;

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
  };
}
