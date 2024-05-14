# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixpkgs-unstable, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/desktop/default.nix
    ./modules/syncthing.nix
    ./modules/vagrant.nix
    ./modules/network.nix
    ./modules/laptop.nix
    ./modules/audio.nix
    ./modules/bluetooth.nix
    ./modules/development.nix
    ./modules/zsh.nix
  ];

  networking.hostName = "dergeraet"; # Define your hostname.

  conf = {
    sway.enable = true;
    # users.name = "momme";
    development.enable = true;
    tailscale.enable = true;
  };

  conf = {
    sway.enable = true;
    development.enable = false;
    tailscale.enable = true;
  };

  sops.age.keyFile = /home/momme/.config/sops/age/keys.txt;

  # virtualbox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "momme" ];

  users.users.momme = {
    isNormalUser = true;
    description = "momme";
    extraGroups = [ "networkmanager" "wheel" "docker" "qemu-libvirtd" "libvirtd"  ];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPGZ1R2leDvakw36bFBa9U7IQruW6DjbHahHfZqTerD6"
    ];
  };


  services.netbird.enable = true; # for netbird service & CLI
  environment.systemPackages = [ pkgs.netbird-ui ]; # for GUI

  systemd.services.NetworkManager-wait-online.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
