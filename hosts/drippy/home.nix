{ config, pkgs, ... }:

{
  home.username = "momme";
  home.homeDirectory = "/home/momme";

  home.packages = [
    acpi
  ];

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "gruvbox_dark_v2";
    };
  };

  programs.git = {
    enable = true;
    userName = "Momme";
    userEmail = "momme@juergensen.me";
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "thefuck" ];
      theme = "bira";
    };
  };

  programs.home-manager.enable = true;
  home.stateVersion = "23.11"; # Never ever change this!
}