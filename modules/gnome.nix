{ pkgs, ... }:

{
  # GNOME Desktop Environment
  services.desktopManager.gnome.enable = true; # Updated renamed option (Wayland + Xorg).
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
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