#!/run/current-system/sw/bin/bash
# Set random wallpaper from wallpapers folder on new workspace using hyprpaper
WALLPAPER_DIR="$HOME/wallpapers"
if [ -d "$WALLPAPER_DIR" ] && [ "$(ls -A "$WALLPAPER_DIR")" ]; then
  # Preload all wallpapers
  find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | while read -r img; do
    hyprctl hyprpaper preload "$img"
  done

  # Get the primary monitor (assuming first monitor)
  MONITOR=$(hyprctl monitors | grep "Monitor" | head -1 | awk '{print $2}')

  # Function to set random wallpaper
  set_random_wallpaper() {
    RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
    if [ -n "$RANDOM_WALLPAPER" ]; then
      hyprctl hyprpaper wallpaper "$MONITOR,$RANDOM_WALLPAPER"
    fi
  }

   # Set initial wallpaper
   set_random_wallpaper

   # Rotate every minute
   ( while true; do sleep 60; set_random_wallpaper; done ) &

   # Listen for Hyprland events
   socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
     # Trigger on workspace change or creation
     if [[ $line == workspace* ]] || [[ $line == createworkspace* ]]; then
       set_random_wallpaper
     fi
   done
fi