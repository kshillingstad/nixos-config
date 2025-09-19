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
    btop
    neovim
    devenv
    direnv
    tmux
    alacritty
    lazygit
    git
    gh
    starship
    opencode
  ];
}
