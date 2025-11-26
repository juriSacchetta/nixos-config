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
# NUOVA SEZIONE: Ambienti di sviluppo (Shells)
    devShells.x86_64-linux = let
      # Definisce il set di pacchetti 'pkgs' per l'architettura x86_64-linux
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      
      # 1. Definiamo la nostra shell "dev-tools" usando mkShell (la funzione standard)
      dev-tools = pkgs.mkShell {
        name = "dev-tools";

        # 2. Definiamo i pacchetti richiesti
        packages = with pkgs; [
          # Strumenti di sistema e diagnostica
          pciutils # Fornisce lspci
          util-linux # Fornisce lsblk (utile per i dischi)
          lm_sensors # Fornisce sensors

          # Strumenti per la Grafica (OpenGL/Vulkan)
          mesa-demos # Fornisce glxinfo
          vulkan-tools # Fornisce vulkaninfo
          glmark2
          vkmark

          # Strumenti per lo Stress Test
          stress-ng

          # Altri strumenti utili
          htop
          neofetch
        ];

        # 3. Variabili d'ambiente (opzionale, ma utile)
        shellHook = ''
          echo "Entering Persistent Nix Shell: dev-tools 🚀"
          echo "Available commands: lspci, glxinfo, vulkaninfo, stress-ng, glmark2, vkmark, htop."
        '';
      };
    };
  };
}

