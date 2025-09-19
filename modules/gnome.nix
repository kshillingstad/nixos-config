{ pkgs, ... }:

{
  # GNOME Desktop Environment
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # GNOME-specific packages
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.caffeine
    gnomeExtensions.custom-osd
    gnomeExtensions.window-gestures
    gnomeExtensions.x11-gestures
  ];
}