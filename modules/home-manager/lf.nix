{ pkgs, ... }:

{
  programs.lf = {
    enable = true;
    extraConfig = 
      let
      previewer = pkgs.writeShellScriptBin "lf_kitty_preview.sh" ''
        file=$1
        w=$2
        h=$3
        x=$4
        y=$5

        if [[ "$( file -Lb --mime-type "$file")" =~ ^image ]]; then
            kitty +kitten icat --silent --stdin no --transfer-mode file --place "${w}x${h}@${x}x${y}" "$file" < /dev/null > /dev/tty
            exit 1
        fi

        pistol "$file"
      '';
      cleaner = pkgs.writeShellScriptBin "lf_kitty_clean.sh" ''
        kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
      '';
      in
      ''
          set cleaner ${cleaner}/bin/lf_kitty_clean.sh
          set previewer ${previewer}/bin/lf_kitty_preview.sh
      '';

  };
}
