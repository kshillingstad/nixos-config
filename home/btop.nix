# Btop system monitor
{ config, lib, ... }:

let
  # Theme configuration - read from current-theme file or default to nord
  currentThemeFile = /home/kyle/.config/current-theme;
  theme = if builtins.pathExists currentThemeFile 
    then lib.strings.removeSuffix "\n" (builtins.readFile currentThemeFile)
    else "nord";
  c = import ../themes/${theme}.nix;
in
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "";
      theme_background = false;
      truecolor = true;
      force_tty = false;
      presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
      vim_keys = true;
      rounded_corners = true;
      graph_symbol = "braille";
      graph_symbol_cpu = "default";
      graph_symbol_mem = "default";
      graph_symbol_net = "default";
      graph_symbol_proc = "default";
      shown_boxes = "cpu mem net proc";
      update_ms = 2000;
      proc_sorting = "cpu lazy";
      proc_reversed = false;
      proc_tree = false;
      proc_colors = true;
      proc_gradient = true;
      proc_per_core = false;
      proc_mem_bytes = true;
      proc_cpu_graphs = true;
      proc_info_smaps = false;
      proc_left = false;
      cpu_graph_upper = "total";
      cpu_graph_lower = "total";
      cpu_invert_lower = true;
      cpu_single_graph = false;
      cpu_bottom = false;
      show_uptime = true;
      check_temp = true;
      cpu_sensor = "Auto";
      show_coretemp = true;
      cpu_core_map = "";
      temp_scale = "celsius";
      base_10_sizes = false;
      show_cpu_freq = true;
      clock_format = "%X";
      background_update = true;
      custom_cpu_name = "";
      disks_filter = "";
      mem_graphs = true;
      mem_below_net = false;
      zfs_arc_cached = true;
      show_swap = true;
      swap_disk = true;
      show_disks = true;
      only_physical = true;
      use_fstab = true;
      zfs_hide_datasets = false;
      disk_free_priv = false;
      show_io_stat = true;
      io_mode = false;
      io_graph_combined = false;
      io_graph_speeds = "";
      net_download = 100;
      net_upload = 100;
      net_auto = true;
      net_sync = false;
      net_iface = "";
      show_battery = "off";
      selected_battery = "Auto";
      log_level = "WARNING";
    };
  };
  
  # Create custom btop theme
  home.file.".config/btop/themes/custom.theme".text = ''
    # Main background, semi-transparent
    main_bg=${c.base00}
    # Text and foreground UI elements
    main_fg=${c.base06}
    # Background of text input widgets like search
    text_bg=${c.base01}
    # Foreground color of text input widgets
    text_fg=${c.base06}
    # Background of selected/focused items
    selected_bg=${c.base0D}
    # Foreground of selected/focused items
    selected_fg=${c.base00}
    # Background of inactive/disabled items
    inactive_bg=${c.base01}
    # Foreground of inactive/disabled items
    inactive_fg=${c.base04}
    # Various UI colors
    title=${c.base0D}
    hi_fg=${c.base08}
    # Graph colors
    graph_color_cpu=${c.base0D}
    graph_color_mem=${c.base0B}
    graph_color_net=${c.base0A}
    graph_color_proc=${c.base0E}
    # Misc colors
    meter_bg=${c.base01}
    meter_fg=${c.base0D}
    proc_misc=${c.base0C}
    # Battery colors
    bat_good=${c.base0B}
    bat_mid=${c.base0A}
    bat_bad=${c.base08}
  '';
}