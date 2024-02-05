{ ... }: {

  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/home-assistant/home-assistant:2023.12";
      extraOptions = [ 
        "--network=host" 
        "--device=/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_5a048f934898ec119665acd044d80d13-if00-port0"
      ];
    };
  };
}