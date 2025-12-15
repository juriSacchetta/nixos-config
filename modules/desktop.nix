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

  # --- COSMIC & Display Manager ---
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # --- GNOME Keyring & Security ---
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.cosmic-greeter.enableGnomeKeyring = true;

  # Portals and Dbus usually go with Desktop
  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-cosmic ];
  };

  programs.dconf.enable = true;
}
