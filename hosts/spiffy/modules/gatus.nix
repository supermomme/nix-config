{ pkgs, ... }: let
  gatusConfigFile = pkgs.writeText "gatus-config" ''
    ui:
      title: "status.momme.world"
    security:
      basic:
        username: "momme"
        password-bcrypt-base64: "JDJhJDEyJDBHWU9velZSWnI3ekkuUGx5VDJkMGVOMGgxRlh6Z2kwczNZRGFOU25GNnhsSDZqTkRzM0l5"
    storage:
      type: sqlite
      path: /db/data.db
    endpoints:
      - name: Frontpage
        url: "https://momme.world"
        interval: 60s
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 500"
      - name: Invidious
        url: "https://yt.momme.world"
        interval: 60s
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 500"
      - name: ntfy
        url: "https://ntfy.momme.world"
        interval: 60s
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 500"
      - name: radicale
        url: "https://radicale.momme.world"
        interval: 60s
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 500"
      - name: WG-Calendar
        url: "https://wg-calendar-generator.momme.world"
        interval: 60s
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 500"
  '';
in {

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
    };
  };
}