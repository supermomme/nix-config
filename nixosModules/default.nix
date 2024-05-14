{ pkgs, lib, ... }: {
  
  imports = [
    ./users.nix
    ./tools.nix
    ./hyprland/hyprland.nix
    ./sway/sway.nix
    ./desktopapps.nix
    ./gaming.nix
    ./audio.nix
    ./development.nix
    ./zsh.nix
    ./nvidia.nix
    ./locale.nix
    ./tailscale.nix
    ./insecure.nix
  ];

  conf = {
    # users true
    # tools true
    hyprland.enable = lib.mkDefault false;
    sway.enable = lib.mkDefault false;
    # desktopapps -> hyprland OR sway
    gaming.enable = lib.mkDefault false;
    # audio true
    development.enable = lib.mkDefault false;
    # zsh true
    nvidia.enable = lib.mkDefault false;
    # locale true
    tailscale.enable = lib.mkDefault false;
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      {
        home.stateVersion = "23.11";
        programs.home-manager.enable = true;
      }
    ];
  };

}