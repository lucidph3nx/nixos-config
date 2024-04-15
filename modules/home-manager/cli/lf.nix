{ pkgs, lib, ... }:{
  options = {
    homeManagerModules.lf.enable =
      lib.mkEnableOption "enables lf";
  };
  config = {
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

              if [[ "$( ${pkgs.file} -Lb --mime-type "$file")" =~ ^image ]]; then
                  kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
                  exit 1
              fi

              ${pkgs.pistol} "$file"
            '';
          cleaner = pkgs.writeShellScriptBin "clean.sh" ''
              kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
          '';
        in
        ''
            set previewer ${previewer}/bin/pv.sh
            set cleaner ${cleaner}/bin/clean.sh
        '';

    };
    xdg.desktopEntries = {
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
