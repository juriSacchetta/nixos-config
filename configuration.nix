{ config, pkgs, pkgs-unstable, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/amd-optimization.nix
    ./modules/desktop.nix
    ./modules/flatpak.nix
  ];

  # --- 1. System & Boot ---
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
    # TEMPORARY: Use 6.17.x until 6.18.x/6.19.x amdgpu bugs are fixed
    # See: https://community.frame.work/t/attn-critical-bugs-in-amdgpu-driver-included-with-kernel-6-18-x-6-19-x/79221
    # kernelPackages = pkgs.linuxPackages_6_17;  # Uncomment to use stable 6.17.x
    kernelPackages = pkgs.linuxPackages_latest;   # Currently 6.18.x with workarounds

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # --- 2. Networking & Services ---
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  services = {
    fprintd.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;

    netbird = {
      enable = true;
      package = pkgs-unstable.netbird;
    };
  };

  virtualisation.docker.enable = true;
  security.polkit.enable = true;

  # --- 3. Locale ---
  time.timeZone = "Europe/Rome";
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

  # --- 4. User & Packages ---
  users.users.js = {
    isNormalUser = true;
    description = "js";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc.lib zlib ];
  programs.zsh.enable = true;

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
    vulkan-loader
  ];

  nixpkgs.config.allowUnfree = true;
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
