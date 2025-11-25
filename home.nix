{ inputs, config, pkgs, ... }:

{
  home.username = "js";
  home.homeDirectory = "/home/js";

  home.packages = with pkgs; [
    neovim
    firefox
    ripgrep
    neofetch
    git
  
  ripgrep
  fd
  git
  wget
  curl

  # Compilatori per Treesitter e LSP
  gcc
  gnumake
  unzip
  nodejs_22 # Per molti LSP
  python3

  # Clipboard support (se usi Wayland/Cosmic)
  wl-clipboard


  spotify
inputs.zen-browser.packages."${pkgs.system}".default
  ];

  programs.git = {
    enable = true;
    userName = "Juri Sacchetta";
    userEmail = "jurisacchetta@gmail.com";
  };

  # Questa versione non toccarla, serve per compatibilità futura
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
