{ inputs, config, lib, pkgs, modulesPath, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./modules/mailserver.nix
    ./modules/caddy.nix
  ];

  security.sudo.wheelNeedsPassword = false;
  users.users.momme = {
    isNormalUser = true;
    extraGroups = [ "wheel" "syncthing" "libvirtd" ];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPGZ1R2leDvakw36bFBa9U7IQruW6DjbHahHfZqTerD6"
    ];
  };

  networking.hostName = "zippity"; # Define your hostname.

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 25 993 587 465 ];
  # services.nginx = {
  #   enable = true;
  #   streamConfig = ''
  #     upstream spiffy-unsecure {
  #       server 100.120.137.91:80;
  #       server [fd7a:115c:a1e0::ca38:895b]:80;
  #     }
  #     upstream spiffy-secure {
  #       server 100.120.137.91:443;
  #       server [fd7a:115c:a1e0::ca38:895b]:443;
  #     }

  #     server {
  #       listen 80;
  #       listen [::]:80;

  #       proxy_pass spiffy-unsecure;
  #     }
  #     server {
  #       listen 443;
  #       listen [::]:443;

  #       proxy_pass spiffy-secure;
  #     }
  #   '';
  # };

  environment.systemPackages = with pkgs; [
    wget
    nano
    git
  ];

  system.stateVersion = "23.05"; # Never ever change this!
}

