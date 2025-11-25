{ inputs, config, pkgs, ... }:

{
  home.username = "js";
  home.homeDirectory = "/home/js";

  # --- 1. PACCHETTI UTENTE ---
  home.packages = with pkgs; [
    # Core
    tmux
    dnsutils
    wget
    curl
    unzip
    ripgrep
    fd
    wl-clipboard

    # Dev
    gcc
    gnumake
    nodejs_22
    python3

    # App
    firefox
    neofetch
    spotify
    inputs.zen-browser.packages."${pkgs.system}".default
  ];

  # --- 2. PROGRAMMI ---
  
  # Configurazione GIT
  programs.git = {
    enable = true;
    userName = "Juri Sacchetta";
    userEmail = "jurisacchetta@gmail.com";
    extraConfig = {
      credential.helper = "store";
      init.defaultBranch = "main";
    };
  };

  # Configurazione ZSH
  programs.zsh = {
	enable = true;
	oh-my-zsh = { # "ohMyZsh" without Home Manager
	    enable = true;
	    plugins = [ "git" "thefuck" ];
	    theme = "robbyrussell";
	};
	shellAliases = {
		cls = "clear";
		update = "sudo nixos-rebuild switch --flake ~/nixos-config";
	};
	history.size = 10000;
  };

  # Configurazione NEOVIM
  programs.neovim = {
    enable = true;
  };

  # --- 3. SERVIZI ---
  services.network-manager-applet.enable = true;
  
  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  # --- 4. STATO ---
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
