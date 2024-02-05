{ config, ... }: let
  inherit (import ./utils.nix) createProxyHost;
in {

  ### invidious (youtube-client)
  services.invidious.enable = true;
  services.postgresql.enable = true;

  services.nginx.virtualHosts."yt.momme.world" = (createProxyHost { sslCert = "momme.world"; targetPort = config.services.invidious.port; });
  services.nginx.virtualHosts."yt.internal.momme.world" = (createProxyHost { sslCert = "internal.momme.world"; targetPort = config.services.invidious.port; });
  services.nginx.virtualHosts."yt.direct.momme.world" = (createProxyHost { sslCert = "direct.momme.world"; targetPort = config.services.invidious.port; });

}