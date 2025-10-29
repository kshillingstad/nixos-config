# Alacritty terminal configuration
{ config, pkgs, lib, ... }:

let
  theme = config.theme or "nord";
  c = import ../themes/${theme}.nix;
 in
{
  # Enable Alacritty; runtime configuration imported from generated YAML below.
  programs.alacritty.enable = true;

  # Managed baseline Alacritty config. Theme overrides or scripts may rewrite
  # this file at runtime; Home Manager ensures a sane base exists first.
  programs.alacritty.settings = {
    # Example for additional file imports (replace deprecated top-level import):
    # general.import = [ "~/.config/alacritty/extra.yml" ];
    font = {
      normal = { family = "Hack Nerd Font"; };
    };
    window = {
      decorations = "none";
      dynamic_title = true;
    };
    scrolling = { history = 10000; };
    cursor = { style = "Block"; };
    selection = { save_to_clipboard = true; };
    live_config_reload = true;
    colors = {
      primary = { background = "${c.base00}"; foreground = "${c.base06}"; };
      normal = {
        black = "${c.base00}";
        red = "${c.base08}";
        green = "${c.base0B}";
        yellow = "${c.base0A}";
        blue = "${c.base0D}";
        magenta = "${c.base0E}";
        cyan = "${c.base0C}";
        white = "${c.base05}";
      };
      bright = {
        black = "${c.base03}";
        red = "${c.base08}";
        green = "${c.base0B}";
        yellow = "${c.base0A}";
        blue = "${c.base0D}";
        magenta = "${c.base0E}";
        cyan = "${c.base0C}";
        white = "${c.base07}";
      };
    };
  };
}
