# Host-specific configuration for bfgpu
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nvidia.nix
    ../../modules/desktop.nix
    ../../modules/devtools.nix
    ../../modules/kernel.nix
    ../../modules/gnome.nix
    ../../modules/hyprland.nix
    ../../modules/user-kyle.nix
    ../../modules/tpm-luks.nix
    #../../modules/sunshine.nix
  ];

  # Host-specific settings
  networking.hostName = "bfgpu";
  
  # TPM + LUKS via reusable module
  my.tpmLuks.devices = {
    "luks-aa186915-f570-4fc8-bb82-41685fd81007" = {
      device = "/dev/disk/by-uuid/aa186915-f570-4fc8-bb82-41685fd81007";
      tpm2 = true;
    };
  };

  # Firewall configuration
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 8080 3000 5173 ];
  networking.firewall.allowedUDPPorts = [ 22 ];

   # User provided by shared module (modules/user-kyle.nix)
}
