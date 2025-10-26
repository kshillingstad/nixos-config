{ config, pkgs, lib, inputs, ... }@args:

let
  # Theme configuration
  theme = args.theme or "nord";
  c = import ./themes/${theme}.nix;
in
{
  imports = [
    ./home/hyprland.nix
    ./home/programs.nix
    ./home/services.nix
    ./home/vscode.nix
    ./home/btop.nix
    ./home/starship.nix
    ./home/fastfetch.nix
    ./home/waybar.nix
  ];

  home.username = "kyle";
  home.homeDirectory = "/home/kyle";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

# Extra packages for Wayland workflow (duplicates at system level are fine)
 home.packages = with pkgs; [
    # Development tools
    git
    vim
    curl
    wget
    # System monitoring
    lm_sensors
    # Bluetooth management
    blueman
    # Media control
    playerctl
    # Wallpaper management
    hyprpaper
    # Session management
    wlogout
    # Additional graphical apps
    spotify
    pavucontrol
    blueman
  ];

  # Copy scripts to home directory
  home.file.".config/waybar/dynamic.sh" = {
    text = ''
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

      # Rotate through system stats
      case $current_state in
          0)
              system_display=" $cpu_usage%"
              next_state=1
              ;;
          1)
              system_display=" $mem_usage"
              next_state=2
              ;;
          2)
              system_display=" $temp"
              next_state=0
              ;;
          *)
              system_display=" $cpu_usage%"
              next_state=1
              ;;
      esac

      # Update state for next rotation
      echo "$next_state" > "$STATE_FILE"

      # Output JSON for Waybar
      echo "{\"text\": \"$system_display\", \"tooltip\": \"CPU: $cpu_usage% | Memory: $mem_usage | Temp: $temp\"}"
    '';
    executable = true;
  };

  home.file.".config/wallpaper-picker.sh" = {
    text = ''
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
    '';
    executable = true;
  };

  home.file.".config/logout.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Simple logout menu using wofi

      OPTIONS="Logout\nReboot\nShutdown\nCancel"
      CHOICE=$(echo -e "$OPTIONS" | wofi --dmenu --prompt="Session Menu" --width=300 --height=200)

      case "$CHOICE" in
          "Logout")
              pkill Hyprland
              ;;
          "Reboot")
              systemctl reboot
              ;;
          "Shutdown")
              systemctl poweroff
              ;;
          "Cancel")
              exit 0
              ;;
      esac
    '';
    executable = true;
  };
}
