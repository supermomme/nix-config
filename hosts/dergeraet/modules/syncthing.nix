{ ... }: {
  services.syncthing = {
    enable = true;
    user = "momme";
    configDir = "/home/momme/.config/syncthing";   # Folder for Syncthing's settings and keys
  };
}