# Starship prompt configuration
{ config, pkgs, inputs, ... }:

{
  programs.starship.enable = true;

  # External starship configuration file managed by Home Manager.
  home.file.".config/starship.toml" = {
    text = ''
format = """
[░▒▓](#a3aed2)\
[   ](bg:#a3aed2 fg:#090c0c)\
[](bg:#769ff0 fg:#a3aed2)\
$directory\
[](fg:#769ff0 bg:#394260)\
$git_branch\
$git_status\
[](fg:#394260 bg:#212736)\
$nix_shell\
$nodejs\
$rust\
$golang\
$php\
$python\
$container\
[](fg:#212736 bg:#1d2230)\
[ ](fg:#1d2230)\
$character
"""

[directory]
style = "fg:#e3e5e5 bg:#769ff0"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = ""
style = "bg:#394260"
format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)"

[git_status]
style = "bg:#394260"
format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)"

[nix_shell]
style = "bg:#212736"
symbol = " "
impure_msg = "[impure shell](bold red)"
pure_msg = "[pure shell](bold green)"
unknown_msg = "[unknown shell](bold yellow)"
format = "[[(  ($name))](fg:#769ff0 bg:#212736)]($style)"

[nodejs]
symbol = ""
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[rust]
symbol = ""
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[golang]
symbol = ""
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[python]
symbol = " "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[aws]
symbol = "  "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[buf]
symbol = " "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[c]
symbol = " "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[docker_context]
symbol = " "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[hg_branch]
symbol = " "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[hostname]
ssh_symbol = " "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[lua]
symbol = " "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[memory_usage]
symbol = "󰍛 "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[meson]
symbol = "󰔷 "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[nim]
symbol = "󰆥 "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[package]
symbol = "󰏗 "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[zig]
symbol = " "
style = "bg:#212736"
format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)"

[os.symbols]
Alpaquita = " "
Alpine = " "
AlmaLinux = " "
Amazon = " "
Android = " "
Arch = " "
Artix = " "
CentOS = " "
Debian = " "
DragonFly = " "
Emscripten = " "
EndeavourOS = " "
Fedora = " "
FreeBSD = " "
Garuda = "󱍓 "
Gentoo = " "
HardenedBSD = "󱾌 "
Illumos = "󰈸 "
Kali = " "
Linux = " "
Mabox = " "
Macos = " "
Manjaro = " "
Mariner = " "
MidnightBSD = " "
Mint = " "
NetBSD = " "
NixOS = " "
OpenBSD = "󰈺 "
openSUSE = " "
OracleLinux = "󰏷 "
Pop = " "
Raspbian = " "
Redhat = " "
RedHatEnterprise = " "
RockyLinux = " "
Redox = "󰌘 "
Solus = "󰠳 "
SUSE = " "
Ubuntu = " "
Unknown = " "
Void = " "
Windows = "󰍲 "
'';
  };
}
