{
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
}