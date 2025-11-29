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

    # Allow traffic on wgnord interface
    networking.firewall.trustedInterfaces = [ "wgnord" ];

    # Make wgnord available system-wide
    environment.systemPackages = [
      pkgs.wgnord
    ];

    # Helper scripts for VPN management
    home-manager.users.ben = {
      home.sessionPath = [ "$HOME/.local/scripts" ];

      home.file.".local/scripts/cli.system.vpnStatus" = {
        executable = true;
        text = /* bash */ ''
          #!/bin/sh

          # Check if JSON output is requested
          if [ "$1" = "json" ]; then
            # JSON output for waybar
            if ${pkgs.iproute2}/bin/ip link show wgnord > /dev/null 2>&1; then
              server_ip="$(sudo ${pkgs.wireguard-tools}/bin/wg show wgnord endpoints 2>/dev/null | ${pkgs.gawk}/bin/awk '{print $2}' | ${pkgs.coreutils}/bin/cut -d: -f1)"
              if [ -n "$server_ip" ]; then
                printf '{"text": "󰌾", "class": "connected", "tooltip": "VPN Connected: %s"}' "$server_ip"
              else
                printf '{"text": "󰌾", "class": "error", "tooltip": "VPN Interface up but no endpoint"}'
              fi
            else
              printf '{"text": "󰌿", "class": "disconnected", "tooltip": "VPN Disconnected"}'
            fi
          else
            # Human-readable output
            if ${pkgs.iproute2}/bin/ip link show wgnord > /dev/null 2>&1; then
              server_ip="$(sudo ${pkgs.wireguard-tools}/bin/wg show wgnord endpoints 2>/dev/null | ${pkgs.gawk}/bin/awk '{print $2}' | ${pkgs.coreutils}/bin/cut -d: -f1)"
              if [ -n "$server_ip" ]; then
                printf "\033[32mConnected to: %s\n\033[0m" "$server_ip"
                exit 0
              else
                printf "\033[33mInterface up but no endpoint found\n\033[0m"
                exit 1
              fi
            else
              printf "\033[31mNo active VPN connection\n\033[0m"
              exit 1
            fi
          fi
        '';
      };

      home.file.".local/scripts/system.networking.vpnConnect" = {
        executable = true;
        text = /* bash */ ''
          #!/bin/sh
          sudo ${pkgs.wgnord}/bin/wgnord c nz
          ${pkgs.libnotify}/bin/notify-send -i security-high -t 2000 -e NordVPN "Connected to vpn"
        '';
      };

      home.file.".local/scripts/system.networking.vpnDisconnect" = {
        executable = true;
        text = /* bash */ ''
          #!/bin/sh
          sudo ${pkgs.wgnord}/bin/wgnord d
          ${pkgs.libnotify}/bin/notify-send -i security-low -t 2000 -e NordVPN "Disconnected from vpn"
        '';
      };
    };

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
        PostUp = ip route add SERVER_IP via $(ip route | awk '/default/ { print $3 }') dev $(ip route | awk '/default/ { print $5 }') || true; ip route add 127.0.0.0/8 dev lo table main priority 1 || true
        PostDown = ip route del SERVER_IP || true

        [Peer]
        PublicKey = SERVER_PUBKEY
        AllowedIPs = 0.0.0.0/1, 128.0.0.0/1, ::/0
        Endpoint = SERVER_IP:51820
        PersistentKeepalive = 25
      '';
      mode = "0644";
    };

    # Copy template and countries files to wgnord directory on activation
    system.activationScripts.wgnord-setup = /* bash */ ''
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
