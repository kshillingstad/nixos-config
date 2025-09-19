# Host-specific configuration for bfgpu
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ../../modules/desktop.nix
    ../../modules/devtools.nix
    ../../modules/kernel.nix
  ];

  # Host-specific settings
  networking.hostName = "bfgpu";
  
  # LUKS encryption for this specific machine
  boot.initrd.luks.devices."luks-e74e8861-32b3-4863-acb0-a3d0d554202d".device = "/dev/disk/by-uuid/e74e8861-32b3-4863-acb0-a3d0d554202d";
  
  # Machine-specific user (you may want to make this configurable)
  users.users.kyle = {
    isNormalUser = true;
    description = "kyle";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };
}