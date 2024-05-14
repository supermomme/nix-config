{ inputs, config, pkgs, lib, options, ... }: {

  options = {
    conf.hyprland.enable = lib.mkEnableOption "enable hyprland";
  };

  config = lib.mkIf config.conf.hyprland.enable {

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      # enableNvidiaPatches = true;
    };

    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.displayManager.sddm.theme = "where_is_my_sddm_theme";

    environment.systemPackages = with pkgs; [
      where-is-my-sddm-theme
      waybar
      wofi
      bemenu
      (pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      }))
      dunst
      libnotify
      kitty

      hyprpaper

      cool-retro-term
      # swaylock-fancy
      # swaylock
      swaylock-effects

      zathura # pdf viewer
      mpv # video viewer
      imv # image viewer
      vlc # media viewer
    ];

    # Fonts
    fonts.packages = with pkgs; [
      jetbrains-mono
      nerd-font-patcher
    ];

    security.pam.services.swaylock = {};

    home-manager.sharedModules = [{
      # Darkmode
      gtk = {
        enable = true;
        theme = {
          name = "Breeze-Dark";
          package = pkgs.libsForQt5.breeze-gtk;
        };
      };

      # Hyprland config
      home.file.".config/hypr/hyprland.conf".source = ./hypr-hyprland.conf;
      home.file.".config/hypr/macchiato.conf".source = ./hypr-macchiato.conf;

      # Wallpaper config
      home.file."background.png".source = builtins.fetchurl {
        url = "https://github.com/XNM1/linux-nixos-hyprland-config-dotfiles/raw/6321fae7d8c7a00432982a08cc81f0f74946bf5a/home/background";
        sha256 = "sha256:0k53gl1visli29vdvjy1kbjarv221jy2hincf1s6kv405jv6561p";
      };
      home.file.".config/hypr/hyprpaper.conf".text = ''
        preload = ~/background.png
        wallpaper = ,~/background.png
        ipc = off
        splash = false
      '';

      # Waybar config
      home.file.".config/waybar/config".source = ./waybar-config;
      home.file.".config/waybar/macchiato.css".source = ./waybar-macchiato.css;
      home.file.".config/waybar/style.css".source = ./waybar-style.css;
    }];
  };
}
