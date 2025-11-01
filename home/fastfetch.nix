# Fastfetch configuration
{ config, pkgs, inputs, lib, ... }:

let
  # Theme configuration - read from current-theme file or default to nord
  currentThemeFile = /home/kyle/.config/current-theme;
  theme = if builtins.pathExists currentThemeFile 
    then lib.strings.removeSuffix "\n" (builtins.readFile currentThemeFile)
    else "nord";
  c = import ../themes/${theme}.nix;
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "auto";
        padding = {
          top = 2;
          right = 4;
        };
      };
      display = {
        separator = " 󰇙 ";
        color = {
          keys = "${c.base06}";
          title = "${c.base0D}";
        };
      };
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "resolution"
        "de"
        "wm"
        "theme"
        "icons"
        "font"
        "terminal"
        "cpu"
        "gpu"
        "memory"
        "disk"
        "battery"
        "localip"
        "publicip"
        "break"
        "colors"
      ];
    };
  };
}