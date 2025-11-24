{
  description = "Nixos config flake";

  inputs = {
    # Nixpkgs: usiamo il ramo unstable per avere software recente (stile Arch)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager: per gestire la /home
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    # Questo evita duplicati delle dipendenze
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          
          # Modulo Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            
            home-manager.users.js = import ./home.nix;

            # Passa gli input anche a home-manager
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
  };
}
