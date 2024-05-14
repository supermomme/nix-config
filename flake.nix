{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.11";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, vscode-server, ... }@inputs: {
    nixosConfigurations = {
      # sudo nixos-rebuild switch --flake .#dergeraet
      dergeraet = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/dergeraet/configuration.nix
          ./nixosModules/default.nix
          # ./modules/base.nix
          # ./modules/locale.nix
          # ./modules/tailscale.nix
          ./modules/openssh.nix
          inputs.sops-nix.nixosModules.sops
        ];
      };

      # sudo nixos-rebuild switch --flake .#dergeraet
      zolo = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [
          ./hosts/zolo/configuration.nix
          ./nixosModules/default.nix
          ./modules/openssh.nix
        ];
      };
    };
  };
}
