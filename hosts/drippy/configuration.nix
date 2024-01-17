{ inputs, config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  networking.hostName = "drippy"; # Define your hostname.

  # WiFi
  networking.wireless.enable = true;
  sops.secrets."wireless.env" = {
    sopsFile = ../../secrets/drippy.yaml;
  };
  networking.wireless.environmentFile = config.sops.secrets."wireless.env".path;
  networking.wireless.networks.Lotti.psk = "@Lotti_PSK@";

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

  users.users.momme.shell = pkgs.zsh;
  programs.zsh.enable = true;
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "momme" = import ./home.nix;
    };
  };


  environment.systemPackages = with pkgs; [
    wget
    nano
  ];

  system.stateVersion = "23.11"; # Never ever change this!

}