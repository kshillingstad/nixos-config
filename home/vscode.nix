# VSCode configuration
{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        arcticicestudio.nord-visual-studio-code
      ];
      userSettings = {
        "workbench.colorTheme" = "Nord";
        "editor.minimap.enabled" = false;
      };
    };
  };
}