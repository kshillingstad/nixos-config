#!/usr/bin/env bash

# Dynamic Waybar module that rotates between CPU, memory, and temperature
# and shows Spotify status with hover details

STATE_FILE="$HOME/.config/waybar/dynamic_state"
INTERVAL=3  # Rotate every 3 seconds

# Create state file if it doesn't exist
mkdir -p "$(dirname "$STATE_FILE")"
if [ ! -f "$STATE_FILE" ]; then
    echo "0" > "$STATE_FILE"
fi

# Read current state
current_state=$(cat "$STATE_FILE")

# Get system stats
cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {printf "%d", usage}')
mem_usage=$(free | grep Mem | awk '{printf "%.1fG", $3/1024/1024}')
temp=$(cat /sys/class/hwmon/hwmon6/temp1_input 2>/dev/null | awk '{printf "%d°C", $1/1000}' || echo "N/A")

# Get Spotify status
spotify_status=$(playerctl -p spotify status 2>/dev/null || echo "stopped")
if [ "$spotify_status" = "Playing" ]; then
    spotify_title=$(playerctl -p spotify metadata title 2>/dev/null | cut -c1-30)
    spotify_artist=$(playerctl -p spotify metadata artist 2>/dev/null | cut -c1-20)
    spotify_info="🎵 $spotify_title - $spotify_artist"
    spotify_icon="🎵"
elif [ "$spotify_status" = "Paused" ]; then
    spotify_info="⏸️ Paused"
    spotify_icon="⏸️"
else
    spotify_info="🎵 No music"
    spotify_icon="🎵"
fi

# Show CPU, memory, and temperature stats side by side
system_display=" $cpu_usage%  $mem_usage  $temp"

# Output JSON for Waybar
echo "{\"text\": \"$system_display $spotify_icon\", \"tooltip\": \"CPU: $cpu_usage% | Memory: $mem_usage | Temp: $temp\\n$spotify_info\"}"