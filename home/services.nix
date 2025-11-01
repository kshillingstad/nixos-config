# Services configuration
{ config, lib, ... }:

let
  # Theme configuration - read from current-theme file or default to nord
  currentThemeFile = /home/kyle/.config/current-theme;
  theme = if builtins.pathExists currentThemeFile 
    then lib.strings.removeSuffix "\n" (builtins.readFile currentThemeFile)
    else "nord";
  c = import ../themes/${theme}.nix;
in
{
  # Mako notifications
  services.mako = {
    enable = true;
    settings = {
      font = "Hack Nerd Font 12";
      background-color = "${c.base00}";
      text-color = "${c.base06}";
      border-color = "${c.base0D}";
      border-size = 2;
      default-timeout = 5000;
    };
  };
}