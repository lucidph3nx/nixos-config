{ config, pkgs, lib, ... }:

{
  options = {
    homeManagerModules.dragon-drop.enable =
      lib.mkEnableOption "enables dragon-drop";
  };
  config = lib.mkIf (config.homeManagerModules.dragon-drop.enable 
          # doesn't work on darwin
          && lib.mkIf pkgs.stdenv.isLinux){
    home.packages = with pkgs; [ xdragon ];
    # lf integration
    programs.lf.exraConfig = lib.mkIf config.homeManagerModules.lf.enable ''
        # dragon
        cmd dragon-out :xdragon -a -x "$fx"
        cmd dragon-in ''${{
          files=$(xdragon -t -x)
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
}
