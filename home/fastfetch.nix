# Fastfetch configuration
{ config, pkgs, inputs, ... }:

let
  theme = config.theme or "nord";
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