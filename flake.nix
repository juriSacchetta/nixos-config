{
  description = "Nixos config flake";

  inputs = {
    # Nixpkgs: usiamo il ramo unstable per avere software recente (stile Arch)
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Passiamo a stable ;)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager: per gestire la /home
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
	specialArgs = { 
  	  inherit inputs; 
  
	  pkgs-unstable = import nixpkgs-unstable {
	    system = "x86_64-linux";
	    config.allowUnfree = true;
	  };
	};
	modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          
          # Modulo Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            
            home-manager.users.js = import ./home.nix;

	    home-manager.extraSpecialArgs = { 
              inherit inputs;
              # Passiamo anche qui l'istanza unstable importata sopra
              pkgs-unstable = import nixpkgs-unstable {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            };
          }
        ];
      };
    };
  };
}
