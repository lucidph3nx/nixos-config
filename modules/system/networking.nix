{...}: {
  # increase network buffer size
  boot.kernel.sysctl."net.core.rmem_max" = 2500000;
  # enable network manager
  networking.networkmanager.enable = true;
}
