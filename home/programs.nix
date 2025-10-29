# Programs configuration
{ config, pkgs, inputs, lib, dconfEnabled ? true, ... }:

let
  theme = config.theme or "nord";
  c = import ../themes/${theme}.nix;
  gui = dconfEnabled; # single flag for GUI/desktop features
in
{
  # Cursor theme (GUI only)
  home.pointerCursor = lib.mkIf gui {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  # GTK theme (GUI only)
  gtk = lib.mkIf gui {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };

  # Qt theme (GUI only)
  qt = lib.mkIf gui {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Alacritty configuration moved to home/alacritty.nix

  # Tmux terminal multiplexer (headless OK)
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

  # Git configuration (headless OK)
  programs.git = {
    enable = true;
    userName = "kyle";
    userEmail = "kyleshillingstad@gmail.com";
  };

  # Neovim (headless OK)
  programs.neovim = {
    enable = true;
  };

  # LazyVim config (headless OK)
  xdg.configFile."nvim" = {
    source = inputs.lazyvim;
    recursive = true;
  };

  # Wofi launcher (GUI only)
  programs.wofi = lib.mkIf gui {
    enable = true;
    settings = {
      allow_markup = true;
      width = 600;
      height = 400;
      location = "center";
      show = "drun,run";
      prompt = "Search...";
      filter_rate = 100;
      allow_images = true;
      gtk_dark_theme = true;
      term = "alacritty";
      exec_search = true;
      hide_search = false;
      normal_window = false;
      layers = "top";
      matching = "fuzzy";
      key_expand = "Tab";
      key_exit = "Escape";
      key_nav_up = "Up";
      key_nav_down = "Down";
      key_nav_forward = "Right";
      key_nav_back = "Left";
      key_submit = "Return";
    };
    style = ''
      @import "/home/kyle/.config/theme-overrides/wofi.css";
      * {
        font-family: 'Hack Nerd Font', monospace;
        font-size: 16px;
      }

      window {
        margin: 0px;
        padding: 20px;
        background-color: ${c.base00};
        opacity: 0.95;
        border-radius: 12px;
        border: 2px solid ${c.base0D};
      }

      #input {
        margin: 0 0 10px 0;
        padding: 12px;
        border: none;
        background-color: ${c.base01};
        color: ${c.base06};
        border-radius: 8px;
        outline: none;
      }

      #input:focus {
        border: 2px solid ${c.base0D};
      }

      #inner-box {
        margin: 0;
        padding: 0;
        border: none;
        background-color: ${c.base00};
      }

      #outer-box {
        margin: 0;
        padding: 0;
        border: none;
        background-color: ${c.base00};
      }

      #scroll {
        margin: 0;
        padding: 0;
        border: none;
        background-color: ${c.base00};
      }

      #text {
        margin: 5px;
        padding: 8px;
        border: none;
        color: ${c.base06};
        border-radius: 6px;
      }

      #entry {
        background-color: ${c.base00};
        border-radius: 6px;
        margin: 2px 0;
      }

      #entry:selected {
        background-color: ${c.base0D};
        color: ${c.base00};
        font-weight: bold;
      }

      #entry:selected #text {
        color: ${c.base00};
      }

      #entry image {
        -gtk-icon-transform: scale(0.8);
        margin-right: 8px;
      }

      #unselected {
        background-color: transparent;
      }

      #selected {
        background-color: ${c.base0D};
      }

      #urgent {
        background-color: ${c.base08};
        color: ${c.base00};
      }
    '';
  };

  # Desktop entries (GUI only)
  xdg.desktopEntries = lib.mkIf gui {
    brave = {
      name = "Brave Browser";
      exec = "brave %U";
      icon = "brave-browser";
      categories = [ "Network" "WebBrowser" ];
      terminal = false;
    };
    alacritty = {
      name = "Alacritty";
      exec = "alacritty";
      icon = "Alacritty";
      categories = [ "System" "TerminalEmulator" ];
      terminal = false;
    };
    thunar = {
      name = "Thunar File Manager";
      exec = "thunar %U";
      icon = "Thunar";
      categories = [ "System" "FileManager" ];
      terminal = false;
    };
    spotify = {
      name = "Spotify";
      exec = "spotify %U";
      icon = "spotify-client";
      categories = [ "AudioVideo" "Audio" ];
      terminal = false;
    };
    vscode = {
      name = "Visual Studio Code";
      exec = "code %U";
      icon = "code";
      categories = [ "Development" "IDE" ];
      terminal = false;
    };
    btop = {
      name = "btop Monitor";
      exec = "alacritty -e btop";
      icon = "utilities-system-monitor";
      categories = [ "System" "Monitor" ];
      terminal = false;
    };
    nvim = {
      name = "Neovim";
      exec = "alacritty -e nvim";
      icon = "nvim";
      categories = [ "Development" "TextEditor" ];
      terminal = false;
    };
    pavucontrol = {
      name = "PulseAudio Volume Control";
      exec = "pavucontrol";
      icon = "multimedia-volume-control";
      categories = [ "AudioVideo" "Audio" ];
      terminal = false;
    };
    blueman = {
      name = "Blueman Manager";
      exec = "blueman-manager";
      icon = "blueman";
      categories = [ "System" "Settings" ];
      terminal = false;
    };
    wallpaper-picker = {
      name = "Wallpaper Picker";
      exec = "/home/kyle/.config/wallpaper-picker.sh";
      icon = "preferences-desktop-wallpaper";
      categories = [ "Graphics" ];
      terminal = false;
    };
    logout = {
      name = "Logout Menu";
      exec = "wlogout -p layer-top";
      icon = "system-log-out";
      categories = [ "System" ];
      terminal = false;
    };
    network-manager = {
      name = "Network Manager";
      exec = "nm-connection-editor";
      icon = "network-wireless";
      categories = [ "System" "Settings" ];
      terminal = false;
    };
  };
}
