{ pkgs, ... }:

{
  services.hardware.openrgb.enable = true;
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
  environment.systemPackages = with pkgs; [
    brave
    discord
    spotify
    gnome-tweaks
    gnomeExtensions.caffeine
    gnomeExtensions.custom-osd
    gnomeExtensions.window-gestures
    gnomeExtensions.x11-gestures
    openrgb-with-all-plugins
    system76-keyboard-configurator
  ];
  programs.steam.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];

  fonts.fontconfig.enable = true;
}
