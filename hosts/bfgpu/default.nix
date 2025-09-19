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
  ];

  # Host-specific settings
  networking.hostName = "bfgpu";
  
  # LUKS encryption for this specific machine with TPM support
  boot.initrd.luks.devices."luks-e74e8861-32b3-4863-acb0-a3d0d554202d" = {
    device = "/dev/disk/by-uuid/e74e8861-32b3-4863-acb0-a3d0d554202d";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  # Enable systemd in initrd for TPM support
  boot.initrd.systemd.enable = true;

  # Enable TPM support
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  # Add systemd-cryptenroll to system packages for managing TPM enrollment
  environment.systemPackages = with pkgs; [
    tpm2-tools
    tpm2-tss
  ];
  
  # Machine-specific user (you may want to make this configurable)
  users.users.kyle = {
    isNormalUser = true;
    description = "kyle";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };
}