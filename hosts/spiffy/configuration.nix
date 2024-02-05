{ inputs, config, lib, pkgs, modulesPath, ... }:
let
  createProxyHost = { sslCert, targetPort, extraConfig ? "" }: {
    forceSSL = true;
    sslCertificateKey = "/var/lib/acme/${sslCert}/key.pem";
    sslCertificate = "/var/lib/acme/${sslCert}/cert.pem";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString(targetPort)}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_ssl_server_name on;
        proxy_pass_header Authorization;
        ${extraConfig}
      '';
    };
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ./modules/homeassistant.nix
    ./modules/invidious.nix
    ./modules/monitoring.nix
    ./modules/ntfy.nix
    ./modules/radicale.nix
    ./modules/samba.nix
    ./modules/wg-calendar-generator.nix
  ];

  networking.hostName = "spiffy"; # Define your hostname.
  networking.firewall.allowPing = false;


  ### acme
  sops.secrets."cloudflare-creds" = { sopsFile = ../../secrets/spiffy.yaml; };
  security.acme = {
    acceptTerms = true;
    defaults.email = "momme+acme@juergensen.me";
    defaults.group = config.services.nginx.group;
    defaults.credentialsFile = config.sops.secrets."cloudflare-creds".path;
    defaults.dnsProvider = "cloudflare";

    certs."momme.world" = {
      extraDomainNames = [ "*.momme.world" ];
    };
    certs."internal.momme.world" = {
      extraDomainNames = [ "*.internal.momme.world" ];
    };
    certs."direct.momme.world" = {
      extraDomainNames = [ "*.direct.momme.world" ];
    };
  };


  ### nginx-proxy
  # networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    appendHttpConfig = ''
      error_log stderr;
      access_log syslog:server=unix:/dev/log combined;
    '';
    # other Nginx options
    virtualHosts.localhost = {
      serverName = "localhost";
      extraConfig = "deny all;";
      root = pkgs.runCommand "testdir" {} ''
        mkdir "$out"
        echo you should not be here > "$out/index.html"
      '';
    };
  };


  # ### syncthing
  # services.syncthing = {
  #   enable = true;
  #   openDefaultPorts = true;
  #   guiAddress = "0.0.0.0:8384";
  #   settings.gui = {
  #     user = "xxx";
  #     password = "xxx";
  #   };
  #   settings.options.urAccepted = -1;
  #   settings.devices = {
  #     "MBP" = { id = "xxx"; };
  #     "ONEPLUS" = { id = "xxx"; };
  #   };
  # };
  # services.nginx.virtualHosts."syncthing.internal.momme.world" = (createProxyHost {
  #   sslCert = "internal.momme.world";
  #   targetPort = 8384;
  #   extraConfig = ''
  #     allow 100.89.69.125; # tailnet MBP
  #     allow fd7a:115c:a1e0:ab12:4843:cd96:6259:457d; # tailnet MBP
  #     deny all;
  #   '';
  # });

  environment.systemPackages = with pkgs; [
    wget
    nano
    git
    kompose
    kubectl
    kubernetes
    yt-dlp
    screen
    android-tools
    openssl
  ];

  system.stateVersion = "23.11"; # Never ever change this!
}

