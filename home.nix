{ config, pkgs, lib, inputs, dconfEnabled ? true, theme ? "nord", ... }@args:

let
  # Theme configuration - read from current-theme file or default to nord
  currentThemeFile = /home/kyle/.config/current-theme;
  theme = if builtins.pathExists currentThemeFile 
    then lib.strings.removeSuffix "\n" (builtins.readFile currentThemeFile)
    else "nord";
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

  # Initialize theme on rebuild if no current theme exists
  home.activation.initTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f "$HOME/.config/current-theme" ]; then
      echo "nord" > "$HOME/.config/current-theme"
    fi
    
    # Always ensure alacritty config exists with current theme
    CURRENT_THEME=$(cat "$HOME/.config/current-theme" 2>/dev/null || echo "nord")
    THEME_COLORS=$(${pkgs.nix}/bin/nix eval --impure --json --expr "import $HOME/nixos-config/themes/$CURRENT_THEME.nix" | ${pkgs.jq}/bin/jq -r 'to_entries[] | "\(.key)=\(.value)"')
    eval "$THEME_COLORS"
    
    mkdir -p "$HOME/.config/alacritty"
    # Remove any existing symlink or file first
    rm -f "$HOME/.config/alacritty/alacritty.toml"
    cat > "$HOME/.config/alacritty/alacritty.toml" << EOF
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
  '';

  # Copy scripts to home directory
  home.file.".config/waybar/dynamic.sh" = {
    text = ''
      #!/usr/bin/env bash

      # Static Waybar module that shows CPU, memory, and temperature all at once

      # Get system stats
      cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {printf "%d", usage}')
      mem_usage=$(free | grep Mem | awk '{printf "%.1fG", $3/1024/1024}')
      # Dynamic GPU temp path discovery (prefer NVIDIA/GPU sensor)
      temp_path=$(for n in /sys/class/hwmon/hwmon*/name; do 
        if grep -qiE 'gpu|nvidia' "$n"; then echo "$(dirname "$n")/temp1_input"; fi; 
      done | head -1)
      if [ -n "$temp_path" ] && [ -r "$temp_path" ]; then
        temp=$(awk '{printf "%dC", $1/1000}' "$temp_path" 2>/dev/null)
      else
        temp="N/A"
      fi

      # Show all stats together
      system_display="󰻠 $cpu_usage% 󰘚 $mem_usage 󰔏 $temp"

      # Output JSON for Waybar
      echo "{\"text\": \"$system_display\", \"tooltip\": \"CPU: $cpu_usage% | Memory: $mem_usage | Temp: $temp\"}"
    '';
    executable = true;
  };

  # GPU status script deployed via Home Manager for all hosts
  home.file.".config/waybar/gpu-status.sh" = {
    text = ''
       #!/usr/bin/env bash
       HOSTNAME=$(hostname)
       if command -v nvidia-smi >/dev/null 2>&1; then
         IFS=',' read -r util temp power memUsed memTotal < <(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,power.draw,memory.used,memory.total --format=csv,noheader,nounits | sed 's/ %,/%,/g')
         if [[ -n "$memUsed" && -n "$memTotal" ]]; then
           memPct=$(awk -v u="$memUsed" -v t="$memTotal" 'BEGIN { printf("%d", (u/t)*100) }')
         else
           memPct="?"
         fi
         
         # Only show power consumption on desktop (non-laptop) systems
         if [[ "$HOSTNAME" == "surface" ]]; then
           text=$(printf "GPU %sW" "$(printf "%.0f" "$power")")
           tooltip=$(printf "NVIDIA GPU Power: %sW" "$(printf "%.0f" "$power")")
         else
           text=$(printf "GPU %sW" "$(printf "%.0f" "$power")")
           tooltip=$(printf "NVIDIA GPU Power: %sW" "$(printf "%.0f" "$power")")
         fi
       else
         # Attempt generic GPU temp via hwmon if no NVIDIA
         temp_path=$(for n in /sys/class/hwmon/hwmon*/name; do if grep -qiE 'gpu|amdgpu' "$n"; then echo "$(dirname "$n")/temp1_input"; fi; done | head -1)
         if [[ -n "$temp_path" && -r "$temp_path" ]]; then
           temp=$(awk '{printf "%d", $1/1000}' "$temp_path")
           text=$(printf "GPU %sC" "$temp")
           tooltip=$(printf "Generic GPU Temp: %sC" "$temp")
         else
           text="GPU N/A"
           tooltip="No GPU stats available"
         fi
       fi
       printf '{"text":"%s","tooltip":"%s"}' "$text" "$tooltip"
    '';
    executable = true;
  };

  home.file.".config/wallpaper-picker.sh" = {
    text = ''
      #!/usr/bin/env bash

      # Wallpaper picker using wofi
       WALLPAPER_DIR="$HOME/nixos-config/wallpapers"

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
