{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    nx.programs.wgnord.enable = lib.mkEnableOption "wgnord NordVPN WireGuard client";
  };

  config = lib.mkIf config.nx.programs.wgnord.enable {
    # Ensure WireGuard is available
    networking.wireguard.enable = true;

    # Make wgnord available system-wide
    environment.systemPackages = [
      pkgs.wgnord
    ];

    # Create wgnord configuration directory with proper permissions
    systemd.tmpfiles.rules = [
      "d /var/lib/wgnord 0755 root root - -"
    ];

    # Create default template.conf
    environment.etc."wgnord-template.conf" = {
      text = ''
        [Interface]
        PrivateKey = PRIVKEY
        Address = 10.5.0.2/32
        DNS = 103.86.96.100,103.86.99.100

        [Peer]
        PublicKey = SERVER_PUBKEY
        AllowedIPs = 0.0.0.0/0, ::/0
        Endpoint = SERVER_IP:51820
        PersistentKeepalive = 25
      '';
      mode = "0644";
    };

    # Copy template and countries files to wgnord directory on activation
    system.activationScripts.wgnord-setup = ''
      if [ ! -f /var/lib/wgnord/template.conf ]; then
        cp /etc/wgnord-template.conf /var/lib/wgnord/template.conf
        chmod 644 /var/lib/wgnord/template.conf
      fi

      # Copy countries files if they don't exist
      if [ ! -f /var/lib/wgnord/countries.txt ]; then
        cp ${pkgs.wgnord}/share/countries.txt /var/lib/wgnord/countries.txt 2>/dev/null || true
      fi
      if [ ! -f /var/lib/wgnord/countries_iso31662.txt ]; then
        cp ${pkgs.wgnord}/share/countries_iso31662.txt /var/lib/wgnord/countries_iso31662.txt 2>/dev/null || true
      fi
    '';
  };
}
