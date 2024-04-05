{ ... }: {

  networking.networkmanager.enable = true;
  # networking.firewall.allowedTCPPorts = [  ];
  # networking.firewall.allowedUDPPorts = [  ];
  networking.firewall.enable = true;
}