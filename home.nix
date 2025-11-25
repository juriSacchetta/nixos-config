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
tmux
  ];

  programs.git = {
    enable = true;
    userName = "Juri Sacchetta";
    userEmail = "jurisacchetta@gmail.com";
    extraConfig = {
      credential.helper = "store";
      init.defaultBranch = "main";
    };
};

  # Questa versione non toccarla, serve per compatibilità futura
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
services.network-manager-applet.enable = true;
services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
}
