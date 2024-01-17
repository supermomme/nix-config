{ inputs, ... }: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops.defaultSopsFile = ../secrets/global.yaml;
  sops.defaultSopsFormat = "yaml";
}