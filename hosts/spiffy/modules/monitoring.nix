{ config, ... }: {
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

  ### Uptime-Kuma
  services.uptime-kuma.enable = true;
}