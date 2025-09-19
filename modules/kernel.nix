{ pkgs, ... }:

{
  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Use Cachyos Kernel
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  services.scx.enable = true;
}
