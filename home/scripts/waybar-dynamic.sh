#!/usr/bin/env bash

# Static Waybar module that shows CPU, memory, and temperature

# Get system stats
cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {printf "%d", usage}')
mem_usage=$(free | grep Mem | awk '{printf "%.1fG", $3/1024/1024}')
temp=$(cat /sys/class/hwmon/hwmon6/temp1_input 2>/dev/null | awk '{printf "%d°C", $1/1000}' || echo "N/A")

# Show CPU, memory, and temperature stats side by side
system_display=" $cpu_usage%  $mem_usage  $temp"

# Output JSON for Waybar
echo "{\"text\": \"$system_display\", \"tooltip\": \"CPU: $cpu_usage% | Memory: $mem_usage | Temp: $temp\"}"