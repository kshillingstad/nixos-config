# NixOS Multi-Machine Configuration

This repository contains a structured NixOS configuration that can be deployed across multiple machines.

## Structure

```
├── base.nix                    # Shared base configuration
├── flake.nix                   # Flake configuration with active hosts
├── home.nix                    # Home Manager configuration with dynamic themes
├── wallpaper.sh                # Wallpaper rotation script with scaling support
├── wallpapers/                 # Curated wallpaper collection (Git LFS)
├── themes/                     # Color scheme definitions for runtime switching
├── modules/                    # Reusable modules
│   ├── desktop.nix            # Desktop environment setup
│   ├── devtools.nix           # Development tools
│   ├── hyprland.nix           # Hyprland window manager
│   ├── greeter.nix            # TUIgreet login manager
│   ├── sunshine.nix           # Sunshine streaming server
│   └── kernel.nix             # Kernel configuration
├── home/                      # Home Manager modules
│   ├── hyprland.nix           # Hyprland configuration with wallpaper scaling
│   ├── waybar.nix             # Status bar configuration
│   ├── alacritty.nix          # Terminal configuration
│   └── scripts/               # User scripts for themes and utilities
└── hosts/                     # Machine-specific configurations
    ├── bfgpu/                 # High-performance workstation with NVIDIA + desktop
    ├── surface/               # Microsoft Surface laptop with Surface-specific tweaks
    └── threadripper/          # Headless compute + ZFS + NVIDIA container
```

## Adding a New Machine

1. **Generate hardware configuration:**
   ```bash
   sudo nixos-generate-config --dir /tmp/new-machine
   ```

2. **Create host directory:**
   ```bash
   mkdir hosts/new-machine-name
   cp /tmp/new-machine/hardware-configuration.nix hosts/new-machine-name/
   ```

3. **Create host configuration:**
   ```bash
   cp hosts/laptop/default.nix hosts/new-machine-name/
   # Edit the file to set hostname and machine-specific settings
   ```

4. **Add to flake.nix:**
   ```nix
   nixosConfigurations = {
     # ... existing configs
     new-machine-name = nixpkgs.lib.nixosSystem {
       modules = [
         ./base.nix
         ./hosts/new-machine-name
         chaotic.nixosModules.default
       ];
     };
   };
   ```

## Building and Switching

**For current machine:**
```bash
sudo nixos-rebuild switch --flake .#hostname
```

**For remote deployment:**
```bash
nixos-rebuild switch --flake .#hostname --target-host user@hostname --use-remote-sudo
```

**Build without switching (test):**
```bash
sudo nixos-rebuild build --flake .#hostname
```

## Current Machines

- **bfgpu**: High-performance workstation with NVIDIA GPU, Hyprland desktop environment, sunshine streaming server
- **surface**: Microsoft Surface laptop with Surface-specific kernel, NVIDIA GPU support, Hyprland desktop environment  
- **threadripper**: Headless compute box with ZFS pool, NVIDIA open kernel driver + container toolkit for GPU workloads, Docker with GPU passthrough

All desktop machines include:
- **Hyprland** window manager with optimized ultrawide monitor support
- **Dynamic theme system** with 8 themes (Nord, Tokyo Night, Catppuccin, etc.)
- **Intelligent wallpaper system** with auto-scaling and quality filtering
- **Custom waybar** with system monitoring and media controls

## Maintenance Commands

### Updating flake inputs
```bash
nix flake update
```

### List generations
```bash
nix-env --list-generations
```

### Garbage collection
```bash
nix-collect-garbage --delete-old
# or for specific generations
nix-collect-garbage --delete-generations 1 2 3

# Run as sudo to collect additional garbage
sudo nix-collect-garbage -d
```

### Clean boot entries
```bash
sudo /run/current-system/bin/switch-to-configuration boot
```

## Desktop Environment & Features

### Window Manager: Hyprland
- Tiling window manager with Wayland
- Keybindings:
  - `Mod + Enter/T`: Terminal (Alacritty)
  - `Mod + B`: Browser (Brave)
  - `Mod + E`: File Manager (Thunar)
  - `Mod + Space`: Application launcher (Wofi)
  - `Mod + W`: Wallpaper picker
  - `Mod + Escape`: Logout menu
  - `Mod + T`: **Theme switcher**
  - `Mod + N`: Network manager
  - `Mod + S`: Screenshot (with region selection)
  - `Mod + Shift + L`: Lock screen

### Theme System
**Runtime theme switching without rebuilding!**

- **Default theme**: Nord (resets on reboot)
- **Available themes**: Nord, Tokyo Night, Solarized Light/Dark, Catppuccin, Dracula, Gruvbox, One Dark
- **Usage**: Press `Mod + T` to cycle through themes instantly
- **What updates**:
  - Waybar (top bar)
  - Alacritty (new terminals)
  - Wofi (application launcher)
  - btop (system monitor)
- **Persistence**: Themes are temporary overrides - system resets to Nord on reboot

### Status Bar: Waybar
- **Modules (left to right)**: Workspaces → Music (Spotify/YouTube) → Network → Audio → Battery → System tray
- **Interactive elements**:
  - Click network icon → Network manager
  - Music info scrolls when text is long
  - Media controls via mouse clicks/scroll

### Applications & Tools
- **Terminal**: Alacritty with theme support
- **Launcher**: Wofi with drun mode (desktop applications only)
- **File manager**: Thunar
- **Browser**: Brave
- **Media**: Spotify with MPRIS integration
- **System monitoring**: btop with custom themes
- **System info**: Fastfetch
- **Wallpaper**: Dynamic picker with Hyprpaper (auto-scaling to prevent stretching)

### Scripts
Located in `home/scripts/`:
- `theme-switcher.sh`: Runtime theme switching
- `wallpaper-picker.sh`: Wallpaper selection
- `waybar-dynamic.sh`: Dynamic waybar modules
- `init-theme.sh`: Initialize theme system

### Wallpaper System
- **Location**: `wallpapers/` directory with curated high-quality images
- **Auto-rotation**: Changes wallpaper every minute and on workspace switches
- **Scaling**: Uses `contain` mode to prevent stretching on ultrawide/multi-monitor setups
- **Picker**: Press `Mod + W` to manually select wallpapers via GUI
- **Quality**: Low-quality images automatically removed to ensure crisp displays

## Notes

- Each machine needs its own `hardware-configuration.nix` generated by `nixos-generate-config`
- LUKS UUIDs are machine-specific and must be updated in each host config
- User configuration centralized in `home.nix` with modular imports
- The base configuration includes common settings like timezone, locale, and basic services
- Theme files are in `themes/` directory using standardized color scheme format
- All configurations use declarative Nix expressions for reproducibility
- Wallpapers stored in Git LFS for efficient repository management
- Hyprpaper configured with `contain` scaling to prevent image distortion on ultrawide displays

## Recent Improvements

### Wallpaper System Enhancements
- **Auto-scaling**: Implemented `contain` mode to prevent stretching on ultrawide monitors
- **Quality filtering**: Removed low-quality wallpapers (< 120KB) for better visual experience
- **Proper paths**: Updated all scripts to use correct `nixos-config/wallpapers/` directory
- **Git LFS integration**: Large wallpaper files managed efficiently via Git LFS

### Theme System Overhaul
- **Runtime switching**: Change themes instantly without system rebuilds
- **Persistent configuration**: Theme selection survives across terminal sessions
- **Comprehensive coverage**: Themes apply to Waybar, Alacritty, Wofi, and btop
- **8 curated themes**: Nord, Tokyo Night, Catppuccin, Dracula, Gruvbox, One Dark, Solarized variants