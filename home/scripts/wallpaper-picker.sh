#!/usr/bin/env bash

# Wallpaper picker using wofi
WALLPAPER_DIR="/home/kyle/nixos-config/wallpapers"

if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Use wofi to select wallpaper
SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | \
    wofi --dmenu --prompt="Select Wallpaper" --conf=/home/kyle/.config/wofi/config --style=/home/kyle/.config/wofi/style.css)

if [ -n "$SELECTED" ]; then
    # Get the primary monitor
    MONITOR=$(hyprctl monitors | grep "Monitor" | head -1 | awk '{print $2}')
    
    # Preload and set the selected wallpaper
    hyprctl hyprpaper preload "$SELECTED"
    hyprctl hyprpaper wallpaper "$MONITOR,$SELECTED"
    
    # Send notification
    notify-send "Wallpaper Changed" "$(basename "$SELECTED")"
fi