{ pkgs, ... }:

{
  # Hyprland Wayland Compositor
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

   # Essential packages for Hyprland
   environment.systemPackages = with pkgs; [
     # Terminal emulator
     alacritty
     
     # Application launcher
     wofi
     
     # Status bar
     waybar
    
    # Notification daemon
    mako
    
     # Wallpaper
     hyprpaper
    
    # File manager
    xfce.thunar
    
    # Screenshot utility
    grim
    slurp
    
    # Screen sharing
    xdg-desktop-portal-hyprland
    
    # Audio control
    pavucontrol
    
    # Network manager applet
    networkmanagerapplet
    
    # Clipboard manager
    wl-clipboard
    
# Brightness control
     brightnessctl
     
     # Network utilities for wallpaper script
     socat
   ];

  # XDG Desktop Portal for screen sharing and file dialogs
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # Enable sound with pipewire (already configured in base, but ensure compatibility)
  security.rtkit.enable = true;
  
  # Polkit for privilege escalation in GUI apps
  security.polkit.enable = true;
  
  # Enable location services for things like night light
  services.geoclue2.enable = true;
}