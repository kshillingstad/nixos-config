{ config, pkgs, lib, ... }:

let
  extraPkgs = with pkgs; [
    tree
    terraform
    azure-cli
    fzf
    zoxide
  ];

  shellAliasesCommon = {
    lzg = "lazygit";
    t = "tree -L 1";
    tt = "tree -L 2";
    ttt = "tree -L 3";
    la = "ls -la";
    tf = "terraform";
  };

  shellAliases = shellAliasesCommon
    // {
      az-sub = "az account list --output table";
      az-switch = "az account set --subscription"; # supply subscription ID/name when using
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      net = "netstat -anp TCP"; # mac-specific netstat variant
    };

in {
  home.packages = extraPkgs;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      expireDuplicatesFirst = true;
      save = 10000;
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      share = true;
    };

    shellAliases = shellAliases;

    initExtra = ''
      if [[ -z "$XDG_CACHE_HOME" ]]; then export XDG_CACHE_HOME="$HOME/.cache"; fi
      mkdir -p "$XDG_CACHE_HOME/zsh"

      autoload -Uz compinit
      compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION" -i

      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'
      zstyle ':completion:*' rehash true
      zstyle ':completion:*' squeeze-slashes true
      setopt COMPLETE_IN_WORD

      bindkey '^[[A' history-beginning-search-backward
      bindkey '^[[B' history-beginning-search-forward

      bindkey -v
      export EDITOR=nvim

      setopt AUTO_CD AUTO_PUSHD PUSHD_SILENT PUSHD_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS EXTENDED_HISTORY SHARE_HISTORY
      setopt NO_BEEP INTERACTIVE_COMMENTS

      eval "$(direnv hook zsh)"
       # zoxide init removed (handled by HM module)

      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';

    ohMyZsh = {
      enable = true;
      plugins = [ "git" "fzf" "terraform" "direnv" "zoxide" ];
      theme = "robbyrussell"; # Starship overrides prompt visuals
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.zoxide.enable = true;
};
