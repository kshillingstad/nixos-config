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
    ../../modules/user-kyle.nix
    ../../modules/tpm-luks.nix
    ../../modules/sunshine.nix
  ];

  # Host-specific settings
  networking.hostName = "bfgpu";
  
  # TPM + LUKS via reusable module
  my.tpmLuks.devices = {
    "luks-e74e8861-32b3-4863-acb0-a3d0d554202d" = {
      device = "/dev/disk/by-uuid/e74e8861-32b3-4863-acb0-a3d0d554202d";
      tpm2 = true;
    };
  };

  environment.systemPackages = (with pkgs; [
    tpm2-tools
    tpm2-tss
  ]);
  
  # User provided by shared module (modules/user-kyle.nix)
}