{ config, pkgs, lib, ... }:{
  options = {
    homeManagerModules.lf.enable =
      lib.mkEnableOption "enables lf";
  };
  config = lib.mkIf config.homeManagerModules.lf.enable {
    programs.lf = {
      enable = true;
      settings = {
        hidden = true;
      };
      extraConfig = 
        let
          previewer = pkgs.writeShellScriptBin "pv.sh" ''
              file=$1
              w=$2
              h=$3
              x=$4
              y=$5

              if [[ "$( ${pkgs.file}/bin/file -Lb --mime-type "$file")" =~ ^image ]]; then
                  kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
                  exit 1
              fi

              ${pkgs.pistol}/bin/pistol "$file"
            '';
          cleaner = pkgs.writeShellScriptBin "clean.sh" ''
              kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
          '';
        in
        ''
            set previewer ${previewer}/bin/pv.sh
            set cleaner ${cleaner}/bin/clean.sh

            # keybindings
            map d
            map dd :cut
            map D :delete

            # dragon
            cmd dragon-out ${pkgs.xdragon}/bin/xdragon -a -x "$fx"
            cmd dragon-in ''${{
              files=$(${pkgs.xdragon}/bin/xdragon -t -x)
              for file in $files
              do
                path=''${file#file://}
                name=$(basename "$path")
                mv "$path" "$(pwd)/$name"
              done
            }}
            map do dragon-out
            map di dragon-in 
        '';

    };
    xdg.desktopEntries = lib.mkIf pkgs.stdenv.isLinux {
        lf = {
          name = "lf";
          genericName = "file manager";
          exec = "kitty lf";
          icon = "utilities-terminal";
          categories = [ "ConsoleOnly" "System" "FileTools" "FileManager"];
          mimeType = ["inode/directory"];
        };
    };
  };
}
