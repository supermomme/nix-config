{ config, pkgs, lib, options, ... }: {

  virtualisation.docker.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode"
    "mongodb-compass"
    "lens-desktop-6.5.2"
  ];

  environment.systemPackages = with pkgs; [
    vscode
    sops
    # gnome.seahorse
    pulumi
    pulumiPackages.pulumi-language-nodejs
    nodejs_18
    mongodb-compass
    kubectl
    kubectx
    vagrant
    lens
  ];
}
