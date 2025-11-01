{ config, pkgs, lib, ... }:
{
  # TUI greetd login using tuigreet; lists all sessions automatically.
  services.greetd = {
    enable = true;
    vt = 1;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --sessions --cmd /run/current-system/sw/bin/bash";
        user = "greeter";
      };
    };
  };

  # Greeter user (locked down)
  users.users.greeter = {
    isNormalUser = false;
    description = "Tuigreet greeter user";
    shell = pkgs.bash;
    group = "nogroup";
  };

  environment.systemPackages = [ pkgs.tuigreet ];

  # Ensure X server available for GNOME sessions and Xorg variant.
  services.xserver.enable = true;
}
