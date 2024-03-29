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

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.05";

  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # nix-shell --command "build-spiffy"
      spiffy = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [ 
          ./hosts/spiffy/configuration.nix
          ./common/common.nix
          ./common/sops.nix
          ./common/users.nix
          ./common/openssh.nix
          ./common/tailscale.nix
        ];
      };

      # nix-shell --command "build-drippy"
      drippy = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [ 
          ./hosts/drippy/configuration.nix
          ./common/common.nix
          ./common/sops.nix
          ./common/users.nix
          ./common/openssh.nix
          ./common/tailscale.nix
          ./common/firewall.nix
          inputs.home-manager.nixosModules.home-manager
        ];
      };

      # nix-shell --command "build-zippity"
      zippity = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [ 
          ./hosts/zippity/configuration.nix
          ./common/common.nix
          ./common/sops.nix
          ./common/users.nix
          ./common/openssh.nix
          ./common/tailscale.nix
          ./common/firewall.nix
        ];
      };
    };
  };
}
