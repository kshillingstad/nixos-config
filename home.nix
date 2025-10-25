{ config, pkgs, ... }:

{
  home.username = "kyle";
  home.homeDirectory = "/home/kyle";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Alacritty terminal emulator
  programs.alacritty = {
    enable = true;
    settings = {
      font.normal.family = "Hack Nerd Font";
      window.decorations = "none";
    };
  };

  # Tmux terminal multiplexer
  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    mouse = true;
    prefix = "C-Space";
    baseIndex = 1;
    keyMode = "vi";
    
    extraConfig = ''
      set-option -sa terminal-overrides ",xterm*:Tc"

      bind C-Space send-prefix

      bind c new-window -c "#{pane_current_path}"

      bind -r C-j resize-pane -D 15
      bind -r C-k resize-pane -U 15
      bind -r C-h resize-pane -L 15
      bind -r C-l resize-pane -R 15

      # Vim style pane selection
      bind h select-pane -L
      bind j select-pane -D 
      bind k select-pane -U
      bind l select-pane -R

      # Vim style window splitting
      bind | split-window -hc "#{pane_current_path}"
      bind - split-window -vc "#{pane_current_path}"

      # Start windows and panes at 1, not 0
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Use Alt-arrow keys without prefix key to switch panes
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Shift arrow to switch windows
      bind -n S-Left  previous-window
      bind -n S-Right next-window

      # Shift Alt vim keys to switch windows
      bind -n M-H previous-window
      bind -n M-L next-window

      set -g @catppuccin_flavour 'mocha'

      setw -g automatic-rename on

      # set vi-mode
      set-window-option -g mode-keys vi
      # keybindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      catppuccin
      yank
      {
        plugin = pkgs.tmuxPlugins.extrakto;
        extraConfig = '''';
      }
    ];
  };

  # Git configuration (if you want to manage this too)
  programs.git = {
    enable = true;
    userName = "kyle";
    userEmail = "kyleshillingstad@gmail.com";
  };

  # Hyprland configuration managed via Home Manager
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true; # manage Hyprland session with systemd user unit
    extraConfig = ''
      # --- Monitors ---
      monitor=,preferred,auto,1

      # --- Environment ---
      env = XCURSOR_SIZE,24
      env = HYPRLAND_LOG_WLR,1

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
        blur = yes
        blur_size = 6
        blur_passes = 2
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

      input {
        kb_layout = us
        follow_mouse = 1
        repeat_rate = 50
        repeat_delay = 300
        touchpad {
          natural_scroll = true
        }
      }

      gestures {
        workspace_swipe = true
      }

      # --- Keybindings ---
      $mod = SUPER
      bind = $mod, Return, exec, alacritty
      bind = $mod, D, exec, rofi -show drun
      bind = $mod, E, exec, thunar
      bind = $mod, L, exec, hyprlock
      bind = $mod, Q, killactive
      bind = $mod, Space, togglefloating
      bind = $mod SHIFT, Q, exit

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

      # --- Exec once on session start ---
      exec-once = swww init
      exec-once = swww img ~/Pictures/wallpapers/default.jpg
      exec-once = waybar
      exec-once = mako

      # Clipboard history (if using wl-clipboard + some script later)
    '';
  };

  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 28;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "temperature" "tray" ];
        clock = { format = "{:%a %Y-%m-%d %H:%M}"; tooltip-format = "{:%A %B %d %Y}"; };
        pulseaudio = { format = " {volume}%"; tooltip = true; };
        network = { format-wifi = "  {essid}"; format-ethernet = "  {ifname}"; format-disconnected = "  offline"; tooltip = true; };
        cpu = { format = " {usage}%"; };
        memory = { format = " {used}/{total}"; };
        temperature = { critical-threshold = 85; format = " {temperatureC}°C"; };
        tray = { spacing = 8; };
      };
    };
    style = ''
      * { font-family: "Hack Nerd Font"; font-size: 12px; }
      window#waybar { background: rgba(30,30,46,0.85); border-bottom: 2px solid #89b4fa; }
      #workspaces button { padding: 0 6px; }
      #clock, #cpu, #memory, #network, #temperature, #pulseaudio { padding: 0 10px; }
      #clock { color: #cdd6f4; }
    '';
  };

  # Mako notifications
  services.mako = {
    enable = true;
    settings = {
      font = "Hack Nerd Font 12";
      background-color = "#1e1e2e";
      text-color = "#cdd6f4";
      border-color = "#89b4fa";
      border-size = 2;
      default-timeout = 5000;
    };
  };

  # Rofi launcher (Wayland build is provided by rofi)
  programs.rofi = {
    enable = true;
    theme = "gruvbox-dark-hard"; # change if desired
    terminal = "alacritty"; # ensures rofi-run uses Alacritty for terminal apps
  };

  # Extra packages for Wayland workflow (duplicates at system level are fine)
  home.packages = with pkgs; [
    swww
    hyprlock
    wl-clipboard
    grim
    slurp
    brightnessctl
    xfce.thunar
    rofi
    pavucontrol
    networkmanagerapplet
  ];
}
