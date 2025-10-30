# Hyprland configuration
{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    systemd.enable = true; # manage Hyprland session with systemd user unit
    extraConfig = ''
      # --- Monitors ---
      monitor=,preferred,auto,1.6
      monitor=,addreserved,10,10,10,10

      # --- Environment ---
      env = XCURSOR_SIZE,32
      env = XCURSOR_THEME,Adwaita

      # --- General Appearance ---
      general {
        gaps_in = 6
        gaps_out = 12
        border_size = 2
        resize_on_border = true
        layout = dwindle
      }

      decoration {
        rounding = 8
        active_opacity = 0.95
        inactive_opacity = 0.85
        blur {
          enabled = yes
          size = 6
          passes = 2
        }
        shadow {
          enabled = yes
          range = 4
          render_power = 3
          color = rgba(1a1a1aee)
        }
      }

      animations {
        enabled = true
        bezier = myBezier,0.05,0.7,0.1,1.0
        animation = windows,1,4,myBezier
        animation = windowsOut,1,4,myBezier
        animation = border,1,4,myBezier
        animation = fade,1,4,myBezier
        animation = workspaces,1,4,myBezier
      }

      misc {
        disable_splash_rendering = true
      }

      input {
        kb_layout = us
        kb_options = caps:escape
        follow_mouse = 1
        repeat_rate = 50
        repeat_delay = 300
        touchpad {
          natural_scroll = true
        }
      }

      gestures {
        workspace_swipe_distance = 300
        workspace_swipe_invert = true
        workspace_swipe_min_speed_to_force = 30
        workspace_swipe_cancel_ratio = 0.5
        workspace_swipe_create_new = true
      }

      # --- Keybindings ---
      $mod = SUPER
      bind = $mod, Return, exec, alacritty
      bind = $mod, T, exec, /home/kyle/.config/theme-picker.sh
      bind = $mod, B, exec, brave
      bind = $mod, E, exec, thunar
      bind = $mod, N, exec, nm-connection-editor
      bind = $mod SHIFT, L, exec, hyprlock
      bind = $mod, Q, killactive
      bind = $mod, Space, exec, wofi --show run
      bind = $mod, W, exec, /home/kyle/.config/wallpaper-picker.sh
      bind = $mod, Escape, exec, /home/kyle/.config/logout.sh
      bind = $mod SHIFT, Q, exec, pkill Hyprland

      # Move focus
      bind = $mod, h, movefocus, l
      bind = $mod, j, movefocus, d
      bind = $mod, k, movefocus, u
      bind = $mod, l, movefocus, r

      # Resize (vim-like)
      bind = $mod CTRL, h, resizeactive, -40 0
      bind = $mod CTRL, l, resizeactive, 40 0
      bind = $mod CTRL, j, resizeactive, 0 40
      bind = $mod CTRL, k, resizeactive, 0 -40

      # Workspaces 1-9
      bind = $mod, 1, workspace,1
      bind = $mod, 2, workspace,2
      bind = $mod, 3, workspace,3
      bind = $mod, 4, workspace,4
      bind = $mod, 5, workspace,5
      bind = $mod, 6, workspace,6
      bind = $mod, 7, workspace,7
      bind = $mod, 8, workspace,8
      bind = $mod, 9, workspace,9
      bind = $mod SHIFT, 1, movetoworkspace,1
      bind = $mod SHIFT, 2, movetoworkspace,2
      bind = $mod SHIFT, 3, movetoworkspace,3
      bind = $mod SHIFT, 4, movetoworkspace,4
      bind = $mod SHIFT, 5, movetoworkspace,5
      bind = $mod SHIFT, 6, movetoworkspace,6
      bind = $mod SHIFT, 7, movetoworkspace,7
      bind = $mod SHIFT, 8, movetoworkspace,8
      bind = $mod SHIFT, 9, movetoworkspace,9

      # Screenshot
      bind = $mod, S, exec, grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png

      # Media keys
      bind = , XF86AudioPlay, exec, playerctl play-pause
      bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+

      # Brightness keys
      bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
      bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
      bind = $mod, Prior, exec, brightnessctl set +10%  # Mod + Page Up
      bind = $mod, Next, exec, brightnessctl set 10%    # Mod + Page Down

# Window rules
           windowrulev2 = noblur, class:(waybar)
           windowrulev2 = noshadow, class:(waybar)

      # --- Exec once on session start ---
      exec-once = hyprpaper
      exec-once = sleep 1 && /home/kyle/nixos-config/wallpaper.sh
      exec-once = waybar
      exec-once = mako
    '';
  };
}