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

  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.gnome.gnome-keyring.enable = true;

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
