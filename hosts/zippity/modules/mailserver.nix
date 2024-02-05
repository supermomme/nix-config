{ inputs, config, pkgs, ... }: {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  ### mailserver
  sops.secrets."mailserver/hashedPassword" = { sopsFile = ../../../secrets/zippity.yaml; };
  mailserver = {
    enable = false; # TODO: set to true to enable the mailserver
    openFirewall = true;
    fqdn = "mail.momme.world";
    domains = [ "momme.world" ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "admin@momme.world" = {
        hashedPasswordFile = config.sops.secrets."mailserver/hashedPassword".path;
        aliases = ["postmaster@momme.world" "security@momme.world"];
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