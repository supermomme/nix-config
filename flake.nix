{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wg-calendar-generator = {
      url = "github:supermomme/wg-calendar-generator";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    momme-world = {
      url = "github:supermomme/momme.world";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # sudo nixos-rebuild switch --flake .#dergeraet
      dergeraet = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/dergeraet/configuration.nix
          ./modules/base.nix
          ./modules/locale.nix
          ./modules/tailscale.nix
          inputs.sops-nix.nixosModules.sops
        ];
      };

      # nix-shell --command "build-spiffy"
      spiffy = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [ 
          ./hosts/spiffy/configuration.nix
          ./modules/base.nix
          ./modules/openssh.nix
          ./modules/tailscale.nix
          ./modules/locale.nix
          ./modules/sops.nix
        ];
      };

      # nix-shell --command "build-zippity"
      zippity = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [ 
          ./hosts/zippity/configuration.nix
          ./modules/base.nix
          ./modules/sops.nix
          ./modules/openssh.nix
          ./modules/locale.nix
          ./modules/tailscale.nix
        ];
      };
    };
  };
}
