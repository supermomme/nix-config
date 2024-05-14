{ inputs, config, pkgs, lib, options, ... }: {

  # TODO: name in options
  # TODO: extraGroups in options

  options = {
    # conf.users.name = lib.mkOption {
    #   type = 
    # };
  };

  config = {

    users.users.momme = {
      isNormalUser = true;
      description = "momme";
      extraGroups = [ "networkmanager" "wheel" "docker" "qemu-libvirtd" "libvirtd"  ];
      packages = with pkgs; [];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPGZ1R2leDvakw36bFBa9U7IQruW6DjbHahHfZqTerD6"
      ];
    };

    home-manager.users.momme = { ... }: {
      home.username = "momme";
      home.homeDirectory = "/home/momme";
    
      programs.git = {
        enable = true;
        userName  = "momme";
        userEmail = "git@momme.world";
        extraConfig = {
          init.defaultBranch = "main";
        };
      };

    };
  };
}
