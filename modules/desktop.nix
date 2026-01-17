{ config, pkgs, ... }:

{
  services.xserver = {
    # enable = true; # Keep your comments if you wish
    xkb = {
      layout = "us";
      variant = "altgr-intl";
    };
  };
  console.useXkbConfig = true;
  # --- BLUETOOTH FIX ---
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # --- COSMIC & Display Manager ---
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # --- GNOME Keyring & Security (Setup Minimale) ---
  services.gnome.gnome-keyring.enable = true;

  # Abilita lo sblocco su TUTTI i possibili greeter
  security.pam.services.cosmic-greeter.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true; # Fallback standard
  security.pam.services.greetd.enableGnomeKeyring =
    true; # Spesso usato sotto cosmic
  # Pacchetti essenziali
  environment.systemPackages = with pkgs; [ seahorse libsecret gcr ];

  # Registra i servizi su D-Bus
  services.dbus.packages = [ pkgs.gcr pkgs.seahorse ];

  # Portals
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-cosmic ];
    config.common.default = "*";
  };

  programs.dconf.enable = true;
}
