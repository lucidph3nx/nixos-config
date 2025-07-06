{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.virt-manager.enable =
      lib.mkEnableOption "enables virt-manager"
      // {
        default = false;
      };
  };
  config = lib.mkIf config.nx.programs.virt-manager.enable {
    programs.virt-manager = {
      enable = true;
    };
    virtualisation = {
      libvirtd.enable = true;
      spiceUSBRedirection.enable = true;
    };
    users.users.ben.extraGroups = [
      "libvirt"
    ];
    environment.persistence."/persist/system" = {
      directories = [
        "/var/lib/libvirt"
        "/var/log/libvirt"
      ];
    };
  };
}
