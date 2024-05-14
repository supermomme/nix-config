{ pkgs, lib, config, ... }: {

  options = {
    conf.gaming.enable = lib.mkEnableOption "enable game mode";
  };

  config = lib.mkIf config.conf.gaming.enable {
    
    # programs.steam = {
    #   enable = true;
    #   gamescope
    #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    # };
    ## Steam
    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
      protonup
      bottles
    ];

    programs.gamemode.enable = true;

  };
}