{ config, ... }: let
  inherit (import ./utils.nix) createProxyHost;
in {

  ### radicale (calendar-server)
  sops.secrets."radicale/htpasswd" = { sopsFile = ../../../secrets/spiffy.yaml; owner = "radicale"; };
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

  sops.secrets."vdirsyncer/radicale/username" = { sopsFile = ../../../secrets/spiffy.yaml; owner = "vdirsyncer-yee"; };
  sops.secrets."vdirsyncer/radicale/password" = { sopsFile = ../../../secrets/spiffy.yaml; owner = "vdirsyncer-yee"; };
  sops.secrets."vdirsyncer/codeanker/url" = { sopsFile = ../../../secrets/spiffy.yaml; owner = "vdirsyncer-yee"; };
  sops.secrets."vdirsyncer/juergensen/url" = { sopsFile = ../../../secrets/spiffy.yaml; owner = "vdirsyncer-yee"; };
  sops.secrets."vdirsyncer/feuerwehr/url" = { sopsFile = ../../../secrets/spiffy.yaml; owner = "vdirsyncer-yee"; };

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
}