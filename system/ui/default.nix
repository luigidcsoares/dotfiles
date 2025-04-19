{ pkgs, ... }: {
  programs.dconf.enable = true;

  # For pinentry-gnome3
  services.dbus.packages = [ pkgs.gcr ];
}
