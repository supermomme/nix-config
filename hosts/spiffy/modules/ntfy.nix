{ ... }: let
  inherit (import ./utils.nix) createProxyHost;
in {
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
}