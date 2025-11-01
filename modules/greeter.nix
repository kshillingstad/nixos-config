{ config, pkgs, lib, ... }:
{
  # TUI greetd login using tuigreet; lists all sessions automatically.
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --kb-sessions 3 --sessions /run/current-system/sw/share/wayland-sessions --xsessions /run/current-system/sw/share/xsessions --cmd /run/current-system/sw/bin/bash";
        user = "greeter";
      };
    };
  };

  # Greeter user (locked down)
  users.users.greeter = {
    isNormalUser = false;
    description = "Tuigreet greeter user";
    shell = pkgs.bash;
    group = lib.mkForce "greeter";
  };

  environment.systemPackages = [ pkgs.tuigreet ];

  # Ensure X server available for GNOME sessions and Xorg variant.
  services.xserver.enable = true;
  
  # Enable display manager for session discovery
  services.displayManager.enable = true;
  
  # Enable GNOME desktop environment to ensure session files are available
  services.desktopManager.gnome.enable = true;

  # New display manager sessionPackages path per deprecation warning
  services.displayManager.sessionPackages = [ 
    pkgs.hyprland
  ]; # Ensure desktop session .desktop files are available
}
