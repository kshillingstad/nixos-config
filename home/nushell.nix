{ config, pkgs, lib, ... }:

{
  programs.nushell = {
    enable = true;
    # Primary configuration (config.nu)
    configFile.text = ''
      # Nushell configuration generated via Home Manager
      # Prompt handled by Starship (initialized in env.nu)

      $env.config = {
        table: { mode: rounded }
        history: {
          max_size: 10000
          file_format: "plaintext"
        }
        hooks: { pre_prompt: [] }
      }

      # Aliases (kept lean; heavy ones live in zsh)
      alias j = jq
      alias y = yq
      alias ll = "ls -l"
      alias la = "ls -a"
      alias htop = btop

      # Data / project helpers
      def csv-preview [path:string] {
        open $path | first 20
      }

      def size-by-ext [] {
        ls **/* | where type == file | group-by extension | each {|it|
          let total = ($it.items | get size | math sum)
          { extension: $it.group, count: ($it.items | length), total: $total }
        } | sort-by total -r
      }

      def json-lines-to-table [] {
        from json | flatten
      }
    '';

    # Environment setup (env.nu)
    envFile.text = ''
      # Starship prompt integration for Nushell
      let cache = ($env.XDG_CACHE_HOME? | default ($env.HOME + "/.cache"))
      mkdir $cache/starship
      starship init nu | save -f $cache/starship/init.nu
      source $cache/starship/init.nu
    '';
  };
}
