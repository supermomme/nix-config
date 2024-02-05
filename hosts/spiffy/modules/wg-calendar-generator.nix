{ inputs, ... }: {
  ### wg-calendar-generator
  services.nginx.virtualHosts."wg-calendar-generator.momme.world" = {
    forceSSL = true;
    sslCertificateKey = "/var/lib/acme/momme.world/key.pem";
    sslCertificate = "/var/lib/acme/momme.world/cert.pem";
    root = inputs.wg-calendar-generator.packages.x86_64-linux.default;
  };
}