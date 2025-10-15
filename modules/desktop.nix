{ pkgs, ... }:

{
  services.hardware.openrgb.enable = true;
  environment.systemPackages = with pkgs; [
    brave
    discord
    spotify
    openrgb-with-all-plugins
    system76-keyboard-configurator
  ];
  programs.steam.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];

  fonts.fontconfig.enable = true;
}
