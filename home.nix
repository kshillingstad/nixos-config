{ config, lib, pkgs, theme ? "nord", ... }:

let
  # Theme configuration
  theme = "nord";
  c = import ./themes/${theme}.nix;
in
{
  imports = [
    ./home/hyprland.nix
    ./home/programs.nix
    ./home/services.nix
    ./home/vscode.nix
  ];

  home.username = "kyle";
  home.homeDirectory = "/home/kyle";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Extra packages for Wayland workflow (duplicates at system level are fine)
  home.packages = with pkgs; [
    hyprlock
    wl-clipboard
    grim
    slurp
    brightnessctl
    xfce.thunar
    wofi
    pavucontrol
    vscode
    networkmanagerapplet
    playerctl
  ];
}
