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
    ## Tools
    kitty # term
    wev # wayland keyboard debug
    wlr-randr # wayland screen rotation/scaling

    ## Browser
    firefox
    chromium
    ranger # file browser in console
    thunderbird

    ## Message
    signal-desktop
    element-desktop
    telegram-desktop
    teams-for-linux

    ## Media
    vlc
    spotify

    ## Misc
    bitwarden
    obsidian
    libreoffice
    okular # PDF Viewer?

    ## More Misc
    slurp # screenshotting
    grim # screenshotting

    ## Fonts
    dejavu_fonts
    font-awesome
    font-awesome_5
    unicode-emoji
  ];
}
