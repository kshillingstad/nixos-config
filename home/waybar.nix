# Waybar configuration
{ config, pkgs, inputs, ... }:

let
  theme = config.theme or "nord";
  c = import ../themes/${theme}.nix;
in
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 26;
        modules-left = [ "hyprland/workspaces" "custom/dynamic" ];
        modules-center = [ "clock" ];
        modules-right = [ "mpris" "custom/sep1" "network" "custom/sep2" "pulseaudio" "custom/sep3" "battery" "tray" ];
        
        clock = { 
          format = "{:%a %m/%d %I:%M %p}"; 
          tooltip-format = "{:%A %B %d %Y}"; 
        };
        
        pulseaudio = { 
          format = " {volume}%"; 
          format-muted = "ﱝ muted";
          on-click = "pavucontrol";
          tooltip-format = "{desc} - {volume}%";
          tooltip = true; 
        };
        
        network = { 
          format-wifi = " "; 
          format-ethernet = " "; 
          format-disconnected = "睊 "; 
          tooltip-format-wifi = "WiFi: {essid}";
          tooltip-format-ethernet = "Ethernet";
          tooltip-format-disconnected = "Disconnected";
          tooltip = true;
          on-click = "nm-connection-editor"; 
        };
        
        
        
        "custom/dynamic" = {
          exec = "/home/kyle/.config/waybar/dynamic.sh";
          format = "{}";
          interval = 3;
          tooltip = true;
          return-type = "json";
        };
        "custom/sep1" = {
          format = "◦";
          tooltip = false;
        };
        "custom/sep2" = {
          format = "◦";
          tooltip = false;
        };
        "custom/sep3" = {
          format = "◦";
          tooltip = false;
        };
        mpris = { 
          format = "{player_icon} {title} - {artist}"; 
          format-paused = "{status_icon} <i>{title} - {artist}</i>";
          ignored-players = [ "firefox" "chromium" ]; 
          player-icons = { 
            default = ""; 
            mpv = ""; 
            spotify = ""; 
            firefox = "";
            chromium = "";
          }; 
          on-click = "playerctl play-pause"; 
          on-click-right = "playerctl next"; 
          on-scroll-up = "playerctl next"; 
          on-scroll-down = "playerctl previous"; 
          tooltip-format = "{player} - {title} - {artist} ({position}/{duration})";
          max-length = 30;
          scroll = true; 
          tooltip = true; 
        };
        
        
        
        battery = { 
          format = "{capacity}% {icon} "; 
          format-charging = "{capacity}%  ";
          format-full = "{capacity}% {icon} ";
          format-icons = ["" "" "" "" ""]; 
          format-time = "{H}h{M}m";
          tooltip-format = "{timeTo} ({power}W)";
          tooltip = true;
          on-click = ""; 
        };
        
        
        
        
        
        tray = { spacing = 8; };
      };
    };
    style = ''
      * { font-family: "Hack Nerd Font"; font-size: 16px; color: ${c.base06}; }
        window#waybar { 
          background: ${c.base00}; 
          margin: 0;
          border-radius: 0;
        }
       #workspaces button { padding: 0 8px; margin: 0 2px; }
       #workspaces button.focused { background: ${c.base0D}; }
       #clock, #cpu, #memory, #network, #temperature, #pulseaudio, #mpris, #battery, #tray { padding: 0 6px; margin: 0 1px; }
     '';
  };
}