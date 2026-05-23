# based on https://github.com/zakkor/shortcut
{
  config,
  pkgs,
}: let
  configFilePath = "${config.xdg.configHome}/.scrc";
  package = pkgs.writeShellScriptBin "shortcut" (builtins.readFile ./shortcut.sh);
  shellAliases = {
    scf = "sc $(cut -d \" \" -f 1  ${configFilePath} | fzf)";
  };
  zshInitContent = ''
    # alias for shortcut package, needed to make sure the parent shell changes directory
    function sc() {
      if [ $2 ]
      then
        if [ ! -f "$SHORTCUT_CONFIG_FILE" ]; then
          touch "$SHORTCUT_CONFIG_FILE"
        fi
        ${package}/bin/shortcut $1 $2
      elif [ "$1" = "--list" ]
      then
        if [ -f "$SHORTCUT_CONFIG_FILE" ]; then
          cat "$SHORTCUT_CONFIG_FILE"
        fi
      elif [ $1 ]
      then
        cd "$(${package}/bin/shortcut $1)" || exit 1
      else
        printf "Usage:\n\tSet shortcut: sc <name> <path>\n\tGo to shortcut: sc <name>\n\tList all existing shortcuts: sc --list\n"
      fi
    }
  '';
in {
  inherit configFilePath package shellAliases zshInitContent;
}
