{ config, pkgs, lib, options, ... }: {
  options = {
    conf.sway.enable = lib.mkEnableOption "enable sway";
  };

  config = lib.mkIf config.conf.sway.enable {

    programs = {
      xwayland.enable = true;
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
          swaylock-fancy
          swayidle
          wl-clipboard
          mako
          alacritty
          wofi
          wofi-emoji
          gnome.adwaita-icon-theme
          i3status-rust
          swayr
          dmenu
          #dmenu-wayland
          xdg-desktop-portal-wlr
          polkit
          polkit_gnome
        ];
      };
    };

    environment.etc."sway/config".source = lib.mkForce (pkgs.callPackage ./build-sway-config.nix {});

    services.xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      # gtk portal needed to make gtk apps happy
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    security.polkit.enable = true;

    systemd.services.polkit-gnome-authentication-agent-1 = {
      enable = true;
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    environment.sessionVariables = { GTK_THEME = "Adwaita:dark"; }; # does this work?

    # do i need extra fonts?
    fonts.fontconfig = {
      enable = true;
    };

    fonts.packages = with pkgs; [
      dejavu_fonts
      font-awesome
      font-awesome_5
      nerdfonts
    ];


    # desktop
    environment.systemPackages = with pkgs; [
      ## Tools
      kitty # term
      wev # wayland keyboard debug
      wlr-randr # wayland screen rotation/scaling


      ## Fonts
      dejavu_fonts
      font-awesome
      font-awesome_5
      unicode-emoji
    ];
  };
}
