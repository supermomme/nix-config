{ config, pkgs, lib, options, ... }: {

  # Laptop settings
  services.thermald.enable = true;

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  environment.systemPackages = with pkgs; [
    acpi # battery stuff
    brightnessctl
    blueberry
  ];
}
