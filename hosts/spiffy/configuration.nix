{ inputs, config, lib, pkgs, modulesPath, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./modules/homeassistant.nix
    ./modules/invidious.nix
    ./modules/monitoring.nix
    ./modules/network.nix
    ./modules/ntfy.nix
    ./modules/radicale.nix
    ./modules/samba.nix
    ./modules/gatus.nix
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

  environment.etc."momme-world-frontpage" = {
    mode = "symlink";
    source = inputs.momme-world.packages.x86_64-linux.default;
  };
  environment.etc."wg-calender-generator" = {
    mode = "symlink";
    source = inputs.wg-calendar-generator.packages.x86_64-linux.default;
  };

  services.nginx = {
    enable = true;
    config = ''
      events {
        worker_connections  4096;
      }
      http {
        include ${pkgs.mailcap}/etc/nginx/mime.types;
        error_log stderr;
        access_log syslog:server=unix:/dev/log combined;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;

        map $http_upgrade $connection_upgrade{
          default upgrade;
          `` close;
        }

        server {
          listen 443 ssl;
          server_name momme.world;
          ssl_certificate /var/lib/acme/momme.world/cert.pem;
          ssl_certificate_key /var/lib/acme/momme.world/key.pem;
          index index.html;
          root html;
          location / {
            root /etc/momme-world-frontpage;
            try_files $uri $uri/ $uri.html =404;
          }
        }

        server {
          listen 443 ssl;
          server_name wg-calendar-generator.momme.world;
          ssl_certificate /var/lib/acme/momme.world/cert.pem;
          ssl_certificate_key /var/lib/acme/momme.world/key.pem;
          index index.html;
          root html;
          location / {
            root /etc/wg-calender-generator;
            try_files $uri $uri/ $uri.html =404;
          }
        }

        server {
          listen 443 ssl;
          server_name radicale.momme.world;
          ssl_certificate /var/lib/acme/momme.world/cert.pem;
          ssl_certificate_key /var/lib/acme/momme.world/key.pem;
          location / {
            proxy_pass http://127.0.0.1:5232;
          }
        }

        server {
          listen 443 ssl;
          server_name ntfy.momme.world;
          ssl_certificate /var/lib/acme/momme.world/cert.pem;
          ssl_certificate_key /var/lib/acme/momme.world/key.pem;
          location / {
            proxy_pass http://127.0.0.1:4363;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
          }
        }

        server {
          listen 443 ssl;
          server_name yt.momme.world;
          ssl_certificate /var/lib/acme/momme.world/cert.pem;
          ssl_certificate_key /var/lib/acme/momme.world/key.pem;
          location / {
            proxy_pass http://127.0.0.1:${toString(config.services.invidious.port)};
          }
        }
        server {
          listen 443 ssl;
          server_name yt.internal.momme.world;
          ssl_certificate /var/lib/acme/internal.momme.world/cert.pem;
          ssl_certificate_key /var/lib/acme/internal.momme.world/key.pem;
          location / {
            proxy_pass http://127.0.0.1:${toString(config.services.invidious.port)};
          }
        }

        server {
          listen 443 ssl;
          server_name uptime.momme.world;
          ssl_certificate /var/lib/acme/momme.world/cert.pem;
          ssl_certificate_key /var/lib/acme/momme.world/key.pem;
          location / {
            proxy_pass http://127.0.0.1:3001;
          }
        }

        server {
          listen 443;
          server_name *.momme.world;
          location / {
            return 404;
          }
        }
      }
    '';
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

