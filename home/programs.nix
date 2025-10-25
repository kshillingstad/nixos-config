# Programs configuration
{ config, pkgs, inputs, c, ... }:

{
  # Alacritty terminal emulator
  programs.alacritty = {
    enable = true;
    settings = {
      font.normal.family = "Hack Nerd Font";
      window.decorations = "none";
      colors = {
        primary = {
          background = "${c.base00}";
          foreground = "${c.base06}";
        };
        normal = {
          black = "${c.base00}";
          red = "${c.base08}";
          green = "${c.base0B}";
          yellow = "${c.base0A}";
          blue = "${c.base0D}";
          magenta = "${c.base0E}";
          cyan = "${c.base0C}";
          white = "${c.base05}";
        };
        bright = {
          black = "${c.base03}";
          red = "${c.base08}";
          green = "${c.base0B}";
          yellow = "${c.base0A}";
          blue = "${c.base0D}";
          magenta = "${c.base0E}";
          cyan = "${c.base0C}";
          white = "${c.base07}";
        };
      };
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

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      # Add custom settings if desired
    };
  };

  # Neovim with LazyVim
  programs.neovim = {
    enable = true;
    # LazyVim config will be managed via xdg.configFile below
  };

  # Manage LazyVim config with Home Manager
  xdg.configFile."nvim" = {
    source = inputs.lazyvim;
    recursive = true;
  };

  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 40;
        modules-left = [ "hyprland/workspaces" "custom/system" ];
        modules-center = [ "clock" ];
          modules-right = [ "pulseaudio" "network" "mpris" "battery" "tray" ];
        clock = { format = "{:%a %m/%d %H:%M}"; tooltip-format = "{:%A %B %d %Y}"; };
        pulseaudio = { format = " {volume}%"; tooltip = true; };
        network = { format-wifi = ""; format-ethernet = ""; format-disconnected = ""; tooltip = true; };
        "custom/system" = {
          exec = "cpu=$(top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print int(100 - $1)}') mem=$(free -h | awk 'NR==2{printf \"%s/%s\", $3,$2}') temp=$(sensors | grep 'Package id 0' | awk '{print int($4) \"°C\"}') echo \" $cpu% $temp  $mem\"";
          format = "{}";
          interval = 5;
          tooltip = true;
        };
          mpris = { format = "{player_icon} {title:.10} - {artist:.10}"; format-paused = "{status_icon} <i>{title:.10} - {artist:.10}</i>"; player-icons = { default = "▶"; mpv = "🎵"; spotify = "🎵"; }; on-click = "playerctl play-pause"; tooltip = true; };
          battery = { format = "{capacity}% {icon}"; format-icons = ["" "" "" "" ""]; tooltip = true; };
          tray = { spacing = 8; };
      };
    };
    style = ''
      * { font-family: "Hack Nerd Font"; font-size: 16px; color: ${c.base06}; }
        window#waybar { background: ${c.base00}; }
       #workspaces button { padding: 0 10px; }
       #workspaces button.focused { background: ${c.base0D}; }
       #clock, #cpu, #memory, #network, #temperature, #pulseaudio, #mpris { padding: 0 10px; }
     '';
  };

  # Wofi launcher
  programs.wofi = {
    enable = true;
    style = ''
      * {
        font-family: 'CaskaydiaMono Nerd Font', monospace;
        font-size: 18px;
      }

      window {
        margin: 0px;
        padding: 20px;
        background-color: ${c.base00};
        opacity: 0.95;
      }

      #inner-box {
        margin: 0;
        padding: 0;
        border: none;
        background-color: ${c.base00};
      }

      #outer-box {
        margin: 0;
        padding: 20px;
        border: none;
        background-color: ${c.base00};
      }

      #scroll {
        margin: 0;
        padding: 0;
        border: none;
        background-color: ${c.base00};
      }

      #input {
        margin: 0;
        padding: 10px;
        border: none;
        background-color: ${c.base00};
        color: ${c.base06};
      }

      #input:focus {
        outline: none;
        box-shadow: none;
        border: none;
      }

      #text {
        margin: 5px;
        border: none;
        color: ${c.base06};
      }

      #entry {
        background-color: ${c.base00};
      }

      #entry:selected {
        outline: none;
        border: none;
      }

      #entry:selected #text {
        color: ${c.base02};
      }

      #entry image {
        -gtk-icon-transform: scale(0.7);
      }
    '';
  };
}