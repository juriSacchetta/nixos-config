{ inputs, config, pkgs, ... }:

{
  home = {
    username = "js";
    homeDirectory = "/home/js";

    # --- 1. PACCHETTI UTENTE ---
    packages = with pkgs; [
      # Core
      tmux
      dnsutils
      wget
      curl
      unzip
      ripgrep
      fd
      wl-clipboard

      # Tool per la Shell (Aggiunti dal tuo .zshrc)
      eza # Per gli alias ls, ll, lt
      bat # Per le funzioni di preview

      # Dev
      gcc
      gnumake
      nodejs_22
      (python3.withPackages (p: [ p.ipython ]))
      gh

      tree
      # App
      firefox
      neofetch
      spotify
      inputs.zen-browser.packages."${pkgs.system}".default

      # --- FONT ---
      # Font di base per una buona copertura Unicode/Emoji
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji

      # Icone per barre di stato e applicazioni
      font-awesome

      # Nerd Fonts (Cruciali per P10K e Neovim)
      # Usa il namespace 'nerd-fonts' per installare solo quelli che ti servono
      nerd-fonts.jetbrains-mono # Ottimo per il coding
      nerd-fonts.fira-code # Altra ottima scelta con legature
      nerd-fonts.meslo-lg # Raccomandato ufficialmente da Powerlevel10k
      nerd-fonts.symbols-only # Se vuoi solo le icone

      # Packages per LazyVim
      statix
      nil
      nixfmt-classic
      birdtray

      # ✅ RUST Toolchain Completa
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer

      zed
      chromium

      man-pages
      man-pages-posix
    ];
    sessionVariables = {
      # Forza le app Electron a usare Wayland nativo (risparmio CPU/Batteria)
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  home.file.".tmux.conf" = {
    source = "${inputs.oh-my-tmux}/.tmux.conf";
    # Rendi la copia gestita da Nix. Non modificarla direttamente.
  };

  home.file.".tmux.conf.local" = {
    source = "${inputs.oh-my-tmux}/.tmux.conf.local";
    # Copia questo file in modo che tu possa modificarlo localmente 
    # (o Home Manager lo creerà se non esiste)
  };
  programs = {
    ssh = {
      enable = true;
      addKeysToAgent = "yes";
    };
    direnv = {
      enable = true;
      enableZshIntegration = true; # Hooks into your Zsh automatically
      nix-direnv.enable = true; # Better caching for Nix
    };

    thunderbird = {
      enable = true;
      profiles.js = { isDefault = true; };
    };
    alacritty = {
      enable = true;
      settings = {
        window = {
          padding = {
            x = 0;
            y = 0;
          };
          opacity = 0.98;
        };

        scrolling = { history = 10000; };

        font = {
          normal = { family = "MesloLGS Nerd Font"; };
          size = 11.0;
          offset = {
            x = 0;
            y = 0;
          };
        };

        bell = { duration = 0; };
      };
    };

    git = {
      enable = true;
      package = pkgs.git.override { withLibsecret = true; };
      userName = "Juri Sacchetta";
      userEmail = "jurisacchetta@gmail.com";
      extraConfig = {
        core.editor = "nvim";
        # credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
        credential.helper = "libsecret";
        init.defaultBranch = "main";
      };
    };
    zsh = {
      enable = true;
      enableCompletion = true;

      # Plugin nativi (molto più veloci di Oh My Zsh)
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        cls = "clear";
        update = "sudo nixos-rebuild switch --flake ~/nixos-config";
        ls = "eza --icons";
        ll = "eza -al --icons";
        lt = "eza -a --tree --level=1 --icons";
        cd = "z";
      };
      history.size = 10000;
      initContent = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" ];
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      # Dipendenze extra per far funzionare Treesitter e Mason (se proprio insisti)
      # withNodeJs = true; # Già incluso in molti casi, ma male non fa
      # withPython3 = true;
    };

    vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        vscodevim.vim
        yzhang.markdown-all-in-one
      ];
    };

    fzf.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
  # --- 3. SERVIZI ---
  services.ssh-agent.enable = true;
  services.network-manager-applet.enable = true;

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  # --- 4. STATO ---
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  systemd.user.services.fix-dbus-environment = {
    Unit = {
      Description = "Fix DBus environment variables for Wayland/Cosmic";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      # Esegue esattamente il comando che ti ha funzionato a mano
      ExecStart =
        "${pkgs.bash}/bin/bash -c '${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY'";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
}
