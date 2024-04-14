{ pkgs, config, ... }: let
  gatusConfigFile = pkgs.writeText "gatus-config" ''
    ui:
      title: "status.momme.world"
    alerting:
      email:
        from: ''${MAIL_FROM}
        username: ''${MAIL_USERNAME}
        password: ''${MAIL_PASSWORD}
        host: ''${MAIL_HOST}
        port: 587
        to: ''${MAIL_TO}
        default-alert:
          description: "health check failed"
          send-on-resolved: true
          failure-threshold: 3
          success-threshold: 3
    storage:
      type: sqlite
      path: /db/data.db
    endpoints:
      - name: Frontpage
        url: "https://momme.world"
        interval: 10s
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 500"
      - name: Invidious
        url: "https://yt.momme.world"
        interval: 10s
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 500"
      - name: ntfy
        url: "https://ntfy.momme.world"
        interval: 10s
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 500"
      - name: radicale
        url: "https://radicale.momme.world"
        interval: 10s
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 500"
      - name: WG-Calendar
        url: "https://wg-calendar-generator.momme.world"
        interval: 10s
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 500"
  '';
in {

  sops.secrets."gatus/env" = { sopsFile = ../../../secrets/spiffy.yaml; };

  virtualisation.oci-containers = {
    containers.gatus = {
      volumes = [
        "${gatusConfigFile}:/config/config.yaml"
        "gatus-db:/db"
      ];
      image = "ghcr.io/twin/gatus:v5.8.0";
      ports = [ "1234:8080" ];
      environment = {
        GATUS_CONFIG = "/config";
      };
      environmentFiles = [ config.sops.secrets."gatus/env".path ];
    };
  };
}