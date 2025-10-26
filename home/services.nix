# Services configuration
{ config, ... }:

let
  theme = config.theme or "nord";
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