{ config, pkgs, lib, ... }:
{
  # Use GDM which automatically detects all desktop sessions
  services.displayManager.gdm.enable = true;
  
  # Ensure X server available for GNOME sessions and Xorg variant.
  services.xserver.enable = true;
  
  # Explicitly add Hyprland to session packages so it appears in GDM
  services.displayManager.sessionPackages = [ pkgs.hyprland ];
}
