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


  ### homeassistant
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/home-assistant/home-assistant:2023.12";
      extraOptions = [ 
        "--network=host" 
        "--device=/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_5a048f934898ec119665acd044d80d13-if00-port0"
      ];
    };
  };

  ### ntfy
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.momme.world";
      listen-http = ":4363";
      behind-proxy = true;
      auth-default-access = "write-only";
    };
  };
  services.nginx.virtualHosts."ntfy.momme.world" = (createProxyHost { sslCert = "momme.world"; targetPort = 4363; });


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

  ### wg-calendar-generator
  services.nginx.virtualHosts."wg-calendar-generator.momme.world" = {
    forceSSL = true;
    sslCertificateKey = "/var/lib/acme/momme.world/key.pem";
    sslCertificate = "/var/lib/acme/momme.world/cert.pem";
    root = inputs.wg-calendar-generator.packages.x86_64-linux.default;
  };

  ### samba
  services.samba = {
    enable = true;
    # You will still need to set up the user accounts to begin with:
    # $ sudo smbpasswd -a yourusername

    extraConfig = ''
      workgroup = WORKGROUP
      browseable = yes
      smb encrypt = required
    '';

    shares = {
      camera = {
        path = "/spiffy-data-1/camera/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0640";
        "directory mask" = "0750";
        "force user" = "syncthing";
        "force group" = "syncthing";
      };
      documents = {
        path = "/spiffy-data-1/documents/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0640";
        "directory mask" = "0750";
        "force user" = "momme";
        "force group" = "users";
      };
      music = {
        path = "/spiffy-data-1/Music/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "momme";
        "force group" = "users";
      };
      movies = {
        path = "/spiffy-data-1/movies/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "momme";
        "force group" = "users";
      };
    };
  };


  ### monitoring
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [
            "localhost:${toString config.services.prometheus.exporters.node.port}"
            "localhost:${toString config.services.prometheus.exporters.smartctl.port}"
          ];
        }];
      }
    ];
    exporters = {
      node = {
        enable = true;
        port = 9100;
        enabledCollectors = [
          "logind"
          "systemd"
          "cpu"
        ];
        disabledCollectors = [
          # "textfile"
        ];
      };
      smartctl.enable = true;
    };
  };

  services.grafana = {
    enable = true;
    settings.server.http_port = 3030;
    settings.server.http_addr = "0.0.0.0";
  };

  
  ### invidious (youtube-client)
  services.invidious.enable = true;
  services.postgresql.enable = true;

  services.nginx.virtualHosts."yt.momme.world" = (createProxyHost { sslCert = "momme.world"; targetPort = config.services.invidious.port; });
  services.nginx.virtualHosts."yt.internal.momme.world" = (createProxyHost { sslCert = "internal.momme.world"; targetPort = config.services.invidious.port; });
  services.nginx.virtualHosts."yt.direct.momme.world" = (createProxyHost { sslCert = "direct.momme.world"; targetPort = config.services.invidious.port; });


  ### radicale (calendar-server)
  sops.secrets."radicale/htpasswd" = { sopsFile = ../../secrets/spiffy.yaml; owner = "radicale"; };
  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [ "127.0.0.1:5232" ];
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.sops.secrets."radicale/htpasswd".path;
        # hash function used for passwords. May be `plain` if you don't want to hash the passwords
        htpasswd_encryption = "bcrypt";
      };
    };
  };
  services.nginx.virtualHosts."radicale.momme.world" = (createProxyHost { sslCert = "momme.world"; targetPort = 5232; });


  ### caldav-sync
  users.users."vdirsyncer-yee" = { isSystemUser = true; group = "vdirsyncer-yee"; };
  users.groups."vdirsyncer-yee" = {};

  sops.secrets."vdirsyncer/radicale/username" = { sopsFile = ../../secrets/spiffy.yaml; owner = "vdirsyncer-yee"; };
  sops.secrets."vdirsyncer/radicale/password" = { sopsFile = ../../secrets/spiffy.yaml; owner = "vdirsyncer-yee"; };
  sops.secrets."vdirsyncer/codeanker/url" = { sopsFile = ../../secrets/spiffy.yaml; owner = "vdirsyncer-yee"; };
  sops.secrets."vdirsyncer/juergensen/url" = { sopsFile = ../../secrets/spiffy.yaml; owner = "vdirsyncer-yee"; };
  sops.secrets."vdirsyncer/feuerwehr/url" = { sopsFile = ../../secrets/spiffy.yaml; owner = "vdirsyncer-yee"; };

  services.vdirsyncer = {
    enable = true;
    jobs = {
      yee = {
        user = "vdirsyncer-yee";
        group = "vdirsyncer-yee";
        forceDiscover = true;
        config.storages.outlook = {
          type = "http";
          "url.fetch" = [ "command" "cat" config.sops.secrets."vdirsyncer/codeanker/url".path ];
          read_only = true;
        };
        config.storages.radicale = {
          type = "caldav";
          url = "http://127.0.0.1:5232/momme/";
          auth = "basic";
          "username.fetch" = [ "command" "cat" config.sops.secrets."vdirsyncer/radicale/username".path ];
          "password.fetch" = [ "command" "cat" config.sops.secrets."vdirsyncer/radicale/password".path ];
        };
        config.storages.ics_juergensen = {
          type = "http";
          "url.fetch" = [ "command" "cat" config.sops.secrets."vdirsyncer/juergensen/url".path ];
          read_only = "true";
        };
        config.storages.feuerwehr = {
          type = "http";
          "url.fetch" = [ "command" "cat" config.sops.secrets."vdirsyncer/feuerwehr/url".path ];
          read_only = "true";
        };
        config.pairs.outlook_radicale = {
          a = "outlook";
          b = "radicale";
          collections = [["ca" null "9cab38f0-da1c-6826-b7b3-96926bac5359"]];
          conflict_resolution = "a wins";
        };
        config.pairs.juergensen_radicale = {
          a = "ics_juergensen";
          b = "radicale";
          collections = [["juergensen" null "1ba11dfa-4ccb-8a68-d0be-afbf21c6d1c4"]];
          conflict_resolution = "a wins";
        };
        config.pairs.feuerwehr_radicale = {
          a = "feuerwehr";
          b = "radicale";
          collections = [["feuerwehr" null "fac67698-e187-1284-c5b6-cab8860d5ad9"]];
          conflict_resolution = "a wins";
        };
      };
    };
  };

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

