# VSCode configuration
{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      vscodevim.vim
      # Theme extensions
      sdras.nord-visual-studio-code
      enkia.tokyo-night
      unthrottled-io.kanagawa
      jdinhlife.gruvbox
      sainnhe.everforest
    ];
    userSettings = {
      "workbench.colorTheme" = "Nord";
      "editor.minimap.enabled" = false;
    };
  };
}