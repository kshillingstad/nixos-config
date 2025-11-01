{ pkgs, config, lib, ... }:

{
  # X server not strictly required for headless/container usage; only set driver list when X is enabled elsewhere.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia-container-toolkit.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = lib.mkDefault true; # Allow hosts to override with mkForce or explicit value
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest; # default to latest globally
  };

  # Fix valgrind build issues affecting nvidia drivers
  nixpkgs.config.packageOverrides = pkgs: {
    libdrm = pkgs.libdrm.override { withValgrind = false; };
  };

  # Wayland/NVIDIA environment stability tweaks
  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    __GL_VRR_ALLOWED = "0"; # disable VRR initially; can toggle later
  };
}
