# Example laptop configuration
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop.nix
    ../../modules/devtools.nix
    # Note: Laptop doesn't need kernel.nix or nvidia.nix
  ];

  # Host-specific settings
  networking.hostName = "laptop";
  
  # Laptop-specific settings
  services.tlp.enable = true; # Power management
  services.xserver.libinput.enable = true; # Touchpad support
  
  # Users for this machine
  users.users.kyle = {
    isNormalUser = true;
    description = "kyle";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };
  
  # Add LUKS device UUID here after running nixos-generate-config
  # boot.initrd.luks.devices."luks-UUID".device = "/dev/disk/by-uuid/UUID";
}