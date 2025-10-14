# Host-specific configuration for surface (converted from standalone configuration.nix)
{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.microsoft-surface-common
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

  # GUI already provided by shared modules; NVIDIA provided by shared module; per-host extras here
  programs.firefox.enable = true;

  # Leave system.stateVersion to base.nix (25.05 for new systems)
}
