{ pkgs, lib, ... }: {
  networking.hostName = "spiffy"; # Define your hostname.

  networking.useNetworkd = true;
  networking.useDHCP = false;

  networking.nat.enable = false;
  networking.firewall.enable = false;

  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        chain input {
          type filter hook input priority 0; policy drop;
          ct state { established, related } counter accept
          ct state invalid drop
          iifname lo accept
          icmp type echo-request accept
          tcp dport {ssh, http, https} accept
          iifname tailscale0 tcp dport {8123} accept
          iifname enp0s25 tcp dport {8443} accept

          icmpv6 type echo-request counter accept
          icmpv6 type nd-neighbor-solicit counter accept
          icmpv6 type nd-neighbor-advert counter accept
          icmpv6 type nd-router-solicit counter accept
          icmpv6 type nd-router-advert counter accept
          icmpv6 type mld-listener-query counter accept
          icmpv6 type destination-unreachable counter accept
          icmpv6 type packet-too-big counter accept
          icmpv6 type time-exceeded counter accept
          icmpv6 type parameter-problem counter accept


          iifname enp4s0f1 accept
        }
        chain output {
          type filter hook output priority 0; policy accept;
        }
      }
    '';
  };

  systemd.network = {
    wait-online.anyInterface = true;

    netdevs = {
      "20-vlan20-iot" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan20";
        };
        vlanConfig.Id = 20;
      };
    };

    networks = {
      "00-management" = {
        matchConfig.Name = "enp0s25";
        networkConfig.DHCP = "yes";
        vlan = [
          "vlan20"
        ];
      };
      "21-vlan20-iot" = {
        matchConfig.Name = "vlan20";
        address = [
          "192.0.2.1/24"
        ];
        networkConfig.LinkLocalAddressing = "no";
      };
    };
  };

  ### DHCPv4 Server
  services.kea.dhcp4 = {
    enable = true;
    settings = {

      interfaces-config = {
        interfaces = [
          "vlan20"
        ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      subnet4 = [
        {
          pools = [
            {
              pool = "192.0.2.100 - 192.0.2.240";
            }
          ];
          subnet = "192.0.2.0/24";
        }
      ];
      valid-lifetime = 4000;
    };
  };

  ### Unifi Controller
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "unifi-controller" "mongodb" ];
  services.unifi.enable = true;

  environment.systemPackages = with pkgs; [
    nftables
    tcpdump
  ];
}