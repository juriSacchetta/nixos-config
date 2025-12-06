{ config, pkgs, ... }:

{
  services.flatpak = {
    enable = true;
    remotes = [{
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }];
    packages = [ "com.logseq.Logseq" "com.github.tchx84.Flatseal" ];
    update.onActivation = true;
    uninstallUnmanaged = true;
  };
}
