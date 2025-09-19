# Example server configuration (headless)
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/devtools.nix
    # Note: Server doesn't need desktop.nix, kernel.nix, or nvidia.nix
  ];

  # Host-specific settings
  networking.hostName = "server";
  
  # Server-specific settings
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false; # Key-only auth
  networking.firewall.allowedTCPPorts = [ 22 ]; # SSH
  
  # Disable GUI services for headless operation
  services.xserver.enable = false;
  
  # Users for this machine
  users.users.kyle = {
    isNormalUser = true;
    description = "kyle";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      # Add your SSH public key here
      # "ssh-rsa AAAAB3NzaC1yc2E... your-key-here"
    ];
  };
  
  # Add LUKS device UUID here after running nixos-generate-config
  # boot.initrd.luks.devices."luks-UUID".device = "/dev/disk/by-uuid/UUID";
}