{ pkgs, ... }:

{
  # GNOME Desktop Environment
  services.xserver.desktopManager.gnome.enable = true; # Provide GNOME sessions (Wayland + Xorg).
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ ];
  };

  # GNOME-specific packages
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.caffeine
    gnomeExtensions.custom-osd
    gnomeExtensions.window-gestures
    gnomeExtensions.x11-gestures
  ];
}