#!/usr/bin/env bash

# Simple theme switcher - temporary overrides only
THEME_DIR="/home/kyle/nixos-config/themes"
CONFIG_DIR="/home/kyle/.config"

# Theme list
THEMES=("nord" "tokyo-night" "solarized-light" "solarized-dark" "catppuccin" "dracula" "gruvbox" "onedark")

# Get current theme from file or default to nord
if [ -f "$CONFIG_DIR/current-theme" ]; then
    CURRENT=$(cat "$CONFIG_DIR/current-theme")
else
    CURRENT="nord"
fi

# Find current theme index and get next theme
for i in "${!THEMES[@]}"; do
    if [ "${THEMES[$i]}" = "$CURRENT" ]; then
        NEXT_INDEX=$(( (i + 1) % ${#THEMES[@]} ))
        NEW_THEME="${THEMES[$NEXT_INDEX]}"
        break
    fi
done

# Save new theme
echo "$NEW_THEME" > "$CONFIG_DIR/current-theme"

# Load theme colors using nix eval
THEME_COLORS=$(nix eval --impure --json --expr "import $THEME_DIR/$NEW_THEME.nix" | jq -r 'to_entries[] | "\(.key)=\(.value)"')
eval "$THEME_COLORS"

# Override waybar CSS temporarily
mkdir -p "$CONFIG_DIR/theme-overrides"
cat > "$CONFIG_DIR/theme-overrides/waybar.css" << EOF
* { font-family: "Hack Nerd Font"; font-size: 16px; color: $base06; }
window#waybar { 
  background: $base00; 
  margin: 0;
  border-radius: 0;
 }
#workspaces button { padding: 0 8px; margin: 0 2px; }
#workspaces button.focused { background: $base0D; }
#clock, #cpu, #memory, #network, #temperature, #pulseaudio, #mpris, #battery, #tray { padding: 0 6px; margin: 0 1px; }
EOF

# Override wofi CSS temporarily
mkdir -p "$CONFIG_DIR/theme-overrides"
cat > "$CONFIG_DIR/theme-overrides/wofi.css" << EOF
* {
  font-family: 'Hack Nerd Font', monospace;
  font-size: 16px;
}

window {
  margin: 0px;
  padding: 20px;
  background-color: $base00;
  opacity: 0.95;
  border-radius: 12px;
  border: 2px solid $base0D;
}

#input {
  margin: 0 0 10px 0;
  padding: 12px;
  border: none;
  background-color: $base01;
  color: $base06;
  border-radius: 8px;
  outline: none;
}

#input:focus {
  border: 2px solid $base0D;
}

#inner-box {
  margin: 0;
  padding: 0;
  border: none;
  background-color: $base00;
}

#outer-box {
  margin: 0;
  padding: 0;
  border: none;
  background-color: $base00;
}

#scroll {
  margin: 0;
  padding: 0;
  border: none;
  background-color: $base00;
}

#text {
  margin: 5px;
  padding: 8px;
  border: none;
  color: $base06;
  border-radius: 6px;
}

#entry {
  background-color: $base00;
  border-radius: 6px;
  margin: 2px 0;
}

#entry:selected {
  background-color: $base0D;
  color: $base00;
  font-weight: bold;
}

#entry:selected #text {
  color: $base00;
}

#entry image {
  -gtk-icon-transform: scale(0.8);
  margin-right: 8px;
}

#unselected {
  background-color: transparent;
}

#selected {
  background-color: $base0D;
}

#urgent {
  background-color: $base08;
  color: $base00;
}
EOF

# Override alacritty config temporarily
mkdir -p "$CONFIG_DIR/alacritty"
cat > "$CONFIG_DIR/alacritty/alacritty.toml" << EOF
[font]
normal = { family = "Hack Nerd Font" }

[window]
decorations = "none"
dynamic_title = true

[scrolling]
history = 10000

[cursor]
style = "Block"

[selection]
save_to_clipboard = true

[general]
live_config_reload = true

[colors.primary]
background = "$base00"
foreground = "$base06"

[colors.normal]
black = "$base00"
red = "$base08"
green = "$base0B"
yellow = "$base0A"
blue = "$base0D"
magenta = "$base0E"
cyan = "$base0C"
white = "$base05"

[colors.bright]
black = "$base03"
red = "$base08"
green = "$base0B"
yellow = "$base0A"
blue = "$base0D"
magenta = "$base0E"
cyan = "$base0C"
white = "$base07"
EOF

# Restart waybar with custom CSS
pkill waybar
sleep 0.5
waybar --style="$CONFIG_DIR/theme-overrides/waybar.css" &

# Send notification
notify-send "Theme switched to $NEW_THEME"