{ pkgs, ... }:
{
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
          iifname lo accept
          icmp type echo-request accept
          tcp dport {ssh, http, https} accept
        }
        chain output {
          type filter hook output priority 0; policy accept;
        }
      }
    '';
  };

  systemd.network = {
    wait-online.anyInterface = true;
    networks = {
      "00-management" = {
        matchConfig.Name = "enp0s25";
        networkConfig.DHCP = "yes";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    nftables
    tcpdump
  ];
}