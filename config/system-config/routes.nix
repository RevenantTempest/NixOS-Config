{ config, pkgs, ... }:

{
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "pfsense-routes" ''
        #!/bin/sh
        if [ "$2" != "up" ]; then
          exit 0
        fi

        ${pkgs.iproute2}/bin/ip route add 192.168.1.0/24 via 192.168.122.242 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route add 192.168.120.0/24 via 192.168.122.242 2>/dev/null || true
      '';
      type = "basic";
    }
  ];
}
