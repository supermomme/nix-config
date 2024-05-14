{ config, pkgs, lib, options, ... }: {

  imports = [
    ./sway.nix
    ./suspend-and-hibernate.nix
  ];

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

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "spotify"
    "obsidian"
  ];


  # desktop
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
}
