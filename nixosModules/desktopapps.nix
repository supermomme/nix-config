{ inputs, pkgs, lib, config, ... }: {
  config = lib.mkIf (config.conf.hyprland.enable || config.conf.sway.enable) {
    environment.systemPackages = with pkgs; [
      thunderbird

      ## Message
      signal-desktop
      # element-desktop
      # telegram-desktop
      # teams-for-linux

      ## Media
      vlc
      spotify
      feh # image viewers

      ## Misc
      bitwarden
      obsidian
      # libreoffice
      # okular # PDF Viewer?

      # ## More Misc
      # slurp # screenshotting
      # grim # screenshotting
    ];
    
    home-manager.sharedModules = [{
      programs.firefox = {
        enable = true;
        profiles = {
          default = {
            id = 0;
            name = "default";
            isDefault = true;
            extensions = with inputs.firefox-addons.packages.${pkgs.system}; [ ublock-origin bitwarden ];
          };
        };
      };

      xdg.mimeApps.defaultApplications = {
        "text/html" = ["firefox.desktop"];
        "text/xml" = ["firefox.desktop"];
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
      };
    }];

  };
}