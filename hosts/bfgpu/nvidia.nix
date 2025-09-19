{ pkgs, config, ... }:

{
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia-container-toolkit.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
