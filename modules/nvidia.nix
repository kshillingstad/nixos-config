{ pkgs, config, ... }:

{
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia-container-toolkit.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # Fix valgrind build issues affecting nvidia drivers
  nixpkgs.config.packageOverrides = pkgs: {
    libdrm = pkgs.libdrm.override { withValgrind = false; };
  };
}
