{ ... }: {

  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      # volumes = [ "home-assistant:/config" ];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/twin/gatus:v5.8.0";
      ports = [ "1234:8080" ];
    };
  };
}