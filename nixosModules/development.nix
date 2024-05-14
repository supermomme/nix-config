{ config, pkgs, lib, options, ... }: {

  options = {
    conf.development.enable = lib.mkEnableOption "enable dev mode";
  };

  # TODO: if some desktop then vscode

  config = lib.mkIf config.conf.development.enable {
    virtualisation.docker.enable = true;
    
    virtualisation.virtualbox.host.enable = true;
    virtualisation.virtualbox.host.enableExtensionPack = true;

    environment.systemPackages = with pkgs; [
      vagrant
      turbovnc
    ];


    users.extraGroups.vboxusers.members = [ "momme" ];

    home-manager.sharedModules = [{
      programs.vscode = {
        enable = true;
        extensions = with pkgs.vscode-extensions; [
          yzhang.markdown-all-in-one
          bbenoist.nix
          github.copilot
          ms-vscode-remote.remote-containers
        ];
      };

      programs = {
        direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };

        # zsh.enable = true;
      };
    }];
  };

}
