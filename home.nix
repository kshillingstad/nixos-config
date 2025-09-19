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
}