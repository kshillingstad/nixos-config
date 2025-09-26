# Headless Threadripper host configuration integrated into flake
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nvidia.nix
    ../../modules/devtools.nix
    ../../modules/kernel.nix
    ../../modules/zfs.nix
    ../../modules/user-kyle.nix
    ../../modules/tpm-luks.nix
  ];

  networking.hostName = "threadripper";

  # Preserve original GRUB + LUKS setup (override base.nix systemd-boot)
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1"; # adjust if different
    useOSProber = true;
    enableCryptodisk = true;
  };

  # Keyfile + LUKS now via TPM/LUKS module abstraction
  boot.initrd.secrets."/boot/crypto_keyfile.bin" = null;
  my.tpmLuks.devices = {
    "luks-065901f2-5652-4d3d-b1ba-48569f358729" = {
      device = "/dev/disk/by-uuid/065901f2-5652-4d3d-b1ba-48569f358729";
      keyFile = "/boot/crypto_keyfile.bin";
      tpm2 = false; # set to true if you later enroll TPM
    };
  };

  # ZFS settings carried over (now mostly in modules/zfs.nix)
  boot.zfs.extraPools = [ "Storage" ];
  networking.hostId = "b3c11ff5"; # required for ZFS pool import

  # Headless overrides (base enables these by default)
  services.xserver.enable = lib.mkForce false;
  services.printing.enable = lib.mkForce false;
  services.pipewire.enable = lib.mkForce false;
  security.rtkit.enable = lib.mkForce false;

  # NVIDIA for container workloads (module supplies driver + toolkit)
  # Use open kernel module variant like original config
  hardware.nvidia.open = true;
  virtualization.docker.enableNvidia = true; # merge with devtools rootless settings



  # Keep original system state version (override base 25.05)
  system.stateVersion = lib.mkForce "24.11"; # Do not bump for existing install
}
