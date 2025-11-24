{ config, pkgs, ... }:

{
  # Info utente
  home.username = "js";
  home.homeDirectory = "/home/js";

  # Pacchetti utente (non richiedono sudo!)
  home.packages = with pkgs; [
    htop
    ripgrep
    neofetch
    git
  ];

  # Esempio configurazione git
  programs.git = {
    enable = true;
    userName = "Juri Sacchetta";
    userEmail = "jurisacchetta@gmail.com";
  };

  # Questa versione non toccarla, serve per compatibilità futura
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
