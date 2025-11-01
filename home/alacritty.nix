# Alacritty terminal configuration
{ config, pkgs, lib, ... }:

{
  # Install alacritty package without Home Manager managing the config
  home.packages = [ pkgs.alacritty ];
  
  # Don't use programs.alacritty.enable - let theme scripts manage everything
}
