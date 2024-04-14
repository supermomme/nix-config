{ inputs, ... }:
let
  spiffyIP = "100.120.137.91";
in
{
  services.caddy = {
    enable = true;
    virtualHosts."momme.world".extraConfig = ''
      root * ${inputs.momme-world.packages.x86_64-linux.default}/
      file_server
    '';
    virtualHosts."wg-calendar-generator.momme.world".extraConfig = ''
      root * ${inputs.wg-calendar-generator.packages.x86_64-linux.default}/
      file_server
    '';
    virtualHosts."ntfy.momme.world".extraConfig = ''
      reverse_proxy https://${spiffyIP} {
        transport http {
          tls
          tls_insecure_skip_verify
        }
      }
    '';
    virtualHosts."radicale.momme.world".extraConfig = ''
      reverse_proxy https://${spiffyIP} {
        transport http {
          tls
          tls_insecure_skip_verify
        }
      }
    '';
    virtualHosts."status.momme.world".extraConfig = ''
      reverse_proxy https://${spiffyIP} {
        transport http {
          tls
          tls_insecure_skip_verify
        }
      }
    '';
  };

}