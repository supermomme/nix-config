{ config, pkgs, lib, options, ... }: {

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  environment.systemPackages = with pkgs; [
    ## Tools
    wget
    git
    htop
    openssl
    dig
    vim
    nix-index # indexing nix packages
    iftop # network monitoring
    gparted
    nmap
    bat # cat but with highlighting
    exiftool
    lm_sensors # hardware monitorings
    pciutils # lspci
  ];

}
