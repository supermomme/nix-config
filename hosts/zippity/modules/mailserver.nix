{ inputs, config, pkgs, ... }: {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  ### dns records
  # A mail.momme.world
  # AAAA mail.codeanker.world
  # MX momme.world "mail.momme.world" priority=10
  # TXT _dmarc "v=DMARC1; p=none"
  # TXT mail._domainkey "v=DKIM1; p=xxx"
  # TXT momme.world "v=spf1 a:mail.momme.world -all"

  ### mailserver
  sops.secrets."mailserver/hashedPassword" = { sopsFile = ../../../secrets/zippity.yaml; };
  mailserver = {
    enable = true;
    openFirewall = true;
    fqdn = "mail.momme.world";
    domains = [ "momme.world" ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "admin@momme.world" = {
        hashedPasswordFile = config.sops.secrets."mailserver/hashedPassword".path;
        aliases = ["hello@momme.world"];
        catchAll = ["momme.world"];
      };
    };

    certificateScheme = "acme";
  };


  ### acme
  sops.secrets."cloudflare-creds" = { sopsFile = ../../../secrets/zippity.yaml; };
  security.acme = {
    # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    acceptTerms = true;
    defaults.email = "momme+acme@juergensen.me";
    # defaults.group = config.services.nginx.group;
    defaults.credentialsFile = config.sops.secrets."cloudflare-creds".path;
    defaults.dnsProvider = "cloudflare";

    certs."mail.momme.world" = { };
  };
}