{ config, pkgs, lib, inputs, dconfEnabled ? true, ... }@args:

let
  # Theme configuration - default to nord for build time
  theme = "nord";
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
    ./home/alacritty.nix
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
    # WiFi management
    networkmanagerapplet
    # System utilities
    jq
    procps # for killall
    libnotify # for notify-send
    brightnessctl # for brightness control
    
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

  # Alacritty baseline moved to home/alacritty.nix

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

  home.file.".config/theme-picker.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Theme picker menu using wofi

      THEME_DIR="/home/kyle/nixos-config/themes"
      CONFIG_DIR="/home/kyle/.config"

      # Theme list with display names
      declare -A THEMES=(
        ["nord"]="Nord"
        ["tokyo-night"]="Tokyo Night"
        ["solarized-light"]="Solarized Light"
        ["solarized-dark"]="Solarized Dark"
        ["catppuccin"]="Catppuccin"
        ["dracula"]="Dracula"
        ["gruvbox"]="Gruvbox"
        ["onedark"]="One Dark"
      )

      # Create menu options
      OPTIONS="Nord\nTokyo Night\nSolarized Light\nSolarized Dark\nCatppuccin\nDracula\nGruvbox\nOne Dark\nCancel"

      # Show wofi menu
      CHOICE=$(echo -e "$OPTIONS" | wofi --dmenu --prompt="Select Theme" --width=350 --height=400)

      # Map display names to theme keys
      case "$CHOICE" in
          "Nord")
              SELECTED_THEME="nord"
              ;;
          "Tokyo Night")
              SELECTED_THEME="tokyo-night"
              ;;
          "Solarized Light")
              SELECTED_THEME="solarized-light"
              ;;
          "Solarized Dark")
              SELECTED_THEME="solarized-dark"
              ;;
          "Catppuccin")
              SELECTED_THEME="catppuccin"
              ;;
          "Dracula")
              SELECTED_THEME="dracula"
              ;;
          "Gruvbox")
              SELECTED_THEME="gruvbox"
              ;;
          "One Dark")
              SELECTED_THEME="onedark"
              ;;
          *)
              SELECTED_THEME=""
              ;;
      esac

      # Apply theme or cancel
      if [ "$CHOICE" = "Cancel" ] || [ -z "$SELECTED_THEME" ]; then
          exit 0
      else
      # Load theme colors using nix eval
      THEME_COLORS=$(nix eval --impure --json --expr "import $THEME_DIR/$SELECTED_THEME.nix" | jq -r 'to_entries[] | "\(.key)=\(.value)"')
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
      cat > "$CONFIG_DIR/alacritty/alacritty.yml" << EOF
      font:
        normal:
          family: "Hack Nerd Font"
      window:
        decorations: "none"
      colors:
        primary:
          background: "$base00"
          foreground: "$base06"
        normal:
          black: "$base00"
          red: "$base08"
          green: "$base0B"
          yellow: "$base0A"
          blue: "$base0D"
          magenta: "$base0E"
          cyan: "$base0C"
          white: "$base05"
        bright:
          black: "$base03"
          red: "$base08"
          green: "$base0B"
          yellow: "$base0A"
          blue: "$base0D"
          magenta: "$base0E"
          cyan: "$base0C"
          white: "$base07"
      EOF

      # Save selected theme
      echo "$SELECTED_THEME" > "$CONFIG_DIR/current-theme"

      # Restart waybar with custom CSS
      pkill waybar
      sleep 0.5
      waybar --style="$CONFIG_DIR/theme-overrides/waybar.css" &

      # Send notification
      notify-send "Theme switched to $CHOICE"
      fi
    '';
    executable = true;
  };
}
