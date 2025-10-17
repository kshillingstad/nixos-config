# Host-specific configuration for surface (converted from standalone configuration.nix)
{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop.nix
    ../../modules/devtools.nix
    ../../modules/gnome.nix
    ../../modules/user-kyle.nix
    ../../modules/nvidia.nix
    # Intentionally NOT importing ../../modules/kernel.nix to keep
    # the Surface-specific kernel setting below.
  ];

  networking.hostName = "surface";

  # Preserve original Surface kernel choice from prior configuration.nix
  hardware.microsoft-surface.kernelVersion = "stable";

  # Optimal swap configuration for laptop
  # Zram (compressed RAM) as primary swap - fast and reduces disk wear
  zramSwap = {
    enable = true;
    memoryPercent = 50;  # Use 50% of RAM for zram (recommended for 8GB+ systems)
    algorithm = "zstd";  # Best compression ratio and speed balance
    priority = 100;      # Higher priority than disk swap
  };

  # Disk swap as fallback when zram is full + hibernation support
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8192;      # 8GB for hibernation (needs to fit full RAM contents)
      priority = 10;    # Lower priority than zram
    }
  ];

  # GUI already provided by shared modules; NVIDIA provided by shared module; per-host extras here
  programs.firefox.enable = true;

  # Leave system.stateVersion to base.nix (25.05 for new systems)
}
