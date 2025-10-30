{ pkgs, ... }:


{
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
      daemon.settings.features.cdi = true;
    };
  };
  users.extraGroups.docker.members = ["kyle"];

   environment.systemPackages = with pkgs; [
     gcc
     neofetch
     fastfetch
     neovim
     devenv
     direnv
     tmux
     lazygit
     git
     gh
     git-lfs
     starship
     opencode
     python314
     go
     ripgrep
     fzf
     pciutils
   ];
}
