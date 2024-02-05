{ ... }: {
  ### samba
  services.samba = {
    enable = true;
    # You will still need to set up the user accounts to begin with:
    # $ sudo smbpasswd -a yourusername

    extraConfig = ''
      workgroup = WORKGROUP
      browseable = yes
      smb encrypt = required
    '';

    shares = {
      camera = {
        path = "/spiffy-data-1/camera/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0640";
        "directory mask" = "0750";
        "force user" = "momme";
        "force group" = "users";
      };
      documents = {
        path = "/spiffy-data-1/documents/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0640";
        "directory mask" = "0750";
        "force user" = "momme";
        "force group" = "users";
      };
      music = {
        path = "/spiffy-data-1/Music/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "momme";
        "force group" = "users";
      };
      movies = {
        path = "/spiffy-data-1/movies/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "momme";
        "force group" = "users";
      };
      misc = {
        path = "/spiffy-data-1/misc/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "momme";
        "force group" = "users";
      };
    };
  };
}