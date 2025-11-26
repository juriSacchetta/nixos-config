{ config, pkgs, pkgs-unstable, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "amd_pstate=active" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  hardware = {
    enableAllFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true; # Per compatibilità Steam/Wine

      extraPackages = with pkgs; [
        amdvlk # Vulkan driver for AMD
        mesa
        libvdpau-va-gl
      ];
    };
    #vulkan = {
    #	enable = true;
    #	package = pkgs.vulkan-loader;
    #}; 
  };

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  services = {
    xserver = {
      # enable = true;
      # displayManager.gdm.enable = true;
      # desktopManager.gnome.enable = true;

      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "altgr-intl";
      };
    };
    fstrim.enable = true;
    gnome.gnome-keyring.enable = true;
    displayManager.cosmic-greeter.enable = true;
    desktopManager.cosmic.enable = true;
    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
      settings = {
        # --- Gestione CPU (AMD Ryzen) ---
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # Usa il driver amd-pstate (Active) che hai abilitato nel kernel
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        # --- Ottimizzazioni Piattaforma ---
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        # --- SOGLIE DI CARICA (Cruciale per ThinkPad) ---
        # Ferma la carica all'80% per allungare la vita della batteria
        # Inizia a caricare solo se scende sotto il 75%
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;

        # (Opzionale: se hai una seconda batteria esterna BAT1)
        # START_CHARGE_THRESH_BAT1 = 75;
        # STOP_CHARGE_THRESH_BAT1 = 80;
      };
    };
    dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };
    netbird = {
      enable = true;
      package = pkgs-unstable.netbird;
    };
    fwupd.enable = true;
  };

  programs.dconf.enable = true;
  security.polkit.enable = true;
  programs.zsh.enable = true;
  console.useXkbConfig = true;
  nixpkgs.config.allowUnfree = true;

  users.users.js = {
    isNormalUser = true;
    description = "js";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    git
    netcat-gnu
    seahorse
    networkmanagerapplet
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-cosmic
    vulkan-loader
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
