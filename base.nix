# Base system configuration shared across all machines (minimal, no GUI/audio)
{ config, pkgs, ... }:
{
  # Bootloader defaults (hosts can override e.g. GRUB)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "America/Chicago";

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Allow unfree packages globally
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.extraOptions = ''trusted-users = root kyle'';

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Keep only the last 3 system generations in boot menu
  boot.loader.systemd-boot.configurationLimit = 3;

  # System version for NEW systems only (hosts may override)
  system.stateVersion = "25.05";
}
